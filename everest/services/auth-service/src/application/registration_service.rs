use crate::AppState;
use crate::core::constants::VERIFICATION_TOKEN_EXPIRY_HOURS;
use crate::core::errors::{AppError, AppResult};
use crate::core::utils::Generator;
use crate::domain::entities::{User, UserRegistration};
use crate::domain::enums::{RegistrationStatus, Source, UserRole};
use crate::domain::services::RegistrationService as RegistrationServiceTrait;
use crate::infrastructure::keycloak_client::KeycloakClient;
use async_trait::async_trait;
use chrono::Utc;
use std::collections::HashMap;
use std::sync::Arc;

pub struct RegistrationService {
    state: Arc<AppState>,
}

impl RegistrationService {
    pub fn new(state: Arc<AppState>) -> Self {
        Self { state }
    }
}

#[async_trait]
impl RegistrationServiceTrait for RegistrationService {
    async fn register(
        &self,
        email: String,
        username: String,
        password: String,
        first_name: Option<String>,
        last_name: Option<String>,
        phone: Option<String>,
        source: Source,
        ip_address: Option<String>,
        user_agent: Option<String>,
    ) -> AppResult<UserRegistration> {
        // 1. Check if user already exists locally
        if self.state.user_repo.find_by_email(&email).await?.is_some() {
            return Err(AppError::Conflict("Email already registered".into()));
        }

        // 2. Prepare Keycloak Attributes
        let mut attributes = HashMap::new();
        attributes.insert("network_id".to_string(), vec!["X".to_string()]);
        attributes.insert("station_id".to_string(), vec!["X".to_string()]);
        attributes.insert(
            "source".to_string(),
            vec![format!("{:?}", source).to_lowercase()],
        );

        if let Some(ref p) = phone {
            attributes.insert("phone".to_string(), vec![p.clone()]);
        }

        // 3. Create User in Keycloak (Disabled by default)
        let keycloak_id = self
            .state
            .keycloak_client
            .create_user(&email, &username, &password, Some(attributes))
            .await
            .map_err(|e| AppError::Keycloak(e.to_string()))?;

        // 4. Assign Default 'user' Role in Keycloak
        self.state
            .keycloak_client
            .assign_role(&keycloak_id, "user")
            .await
            .map_err(|e| AppError::Keycloak(e.to_string()))?;

        // 5. Create Local Registration Record
        let expires_at = Utc::now() + chrono::Duration::hours(VERIFICATION_TOKEN_EXPIRY_HOURS);

        let registration = UserRegistration {
            registration_id: Generator::generate_registration_id(),
            email,
            username,
            first_name,
            last_name,
            phone,
            verification_token: Generator::generate_token(),
            status: RegistrationStatus::Created,
            keycloak_id: Some(keycloak_id),
            user_id: None,
            resend_count: 0,
            expires_at,
            verified_at: None,
            created_at: Utc::now(),
            ip_address,
            user_agent,
            source,
        };

        let created = self.state.registration_repo.create(&registration).await?;

        Ok(created)
    }

    async fn verify(&self, email: String, token: String) -> AppResult<User> {
        // Find registration by token
        let mut registration = self
            .state
            .registration_repo
            .find_by_token(&token)
            .await?
            .ok_or_else(|| AppError::NotFound("Invalid verification token".into()))?;

        // Security check: ensure token belongs to the providing email
        if registration.email != email {
            return Err(AppError::BadRequest("Token does not match email".into()));
        }

        if registration.status == RegistrationStatus::Verified {
            return Err(AppError::BadRequest("Already verified".into()));
        }

        if Utc::now() > registration.expires_at {
            registration.status = RegistrationStatus::Expired;
            self.state.registration_repo.update(&registration).await?;
            return Err(AppError::BadRequest("Verification link expired".into()));
        }

        // Extract Keycloak ID safely from Option<String>
        let kc_id = registration.keycloak_id.as_deref().ok_or_else(|| {
            AppError::Internal("Missing Keycloak ID in registration record".into())
        })?;

        // 1. Enable User in Keycloak
        self.state
            .keycloak_client
            .enable_user(kc_id)
            .await
            .map_err(|e| AppError::Keycloak(e.to_string()))?;

        // 2. Create the final User entity in local DB
        let user = User {
            user_id: Generator::generate_user_id(),
            keycloak_id: kc_id.to_string(),
            email: registration.email.clone(),
            username: registration.username.clone(),
            first_name: registration.first_name.clone(),
            last_name: registration.last_name.clone(),
            phone: registration.phone.clone(),
            photo: None,
            is_verified: true,
            role: UserRole::User,
            network_id: "X".to_string(),
            station_id: "X".to_string(),
            source: registration.source.clone(),
            is_active: true,
            deleted_at: None,
            last_login_at: None,
            created_at: Utc::now(),
            updated_at: Utc::now(),
            created_by: None,
            updated_by: None,
        };

        let created_user = self.state.user_repo.create(&user).await?;

        // 3. Update Registration record to link to the new user_id
        registration.status = RegistrationStatus::Verified;
        registration.user_id = Some(created_user.user_id.clone());
        registration.verified_at = Some(Utc::now());
        self.state.registration_repo.update(&registration).await?;

        Ok(created_user)
    }

    async fn resend_verification(&self, email: String) -> AppResult<()> {
        let mut registration = self
            .state
            .registration_repo
            .find_by_email(&email)
            .await?
            .ok_or_else(|| AppError::NotFound("Registration not found".into()))?;

        if registration.status == RegistrationStatus::Verified {
            return Err(AppError::BadRequest("Already verified".into()));
        }

        if registration.resend_count >= 3 {
            return Err(AppError::BadRequest(
                "Maximum resend attempts exceeded".into(),
            ));
        }

        // Update registration state
        registration.expires_at =
            Utc::now() + chrono::Duration::hours(VERIFICATION_TOKEN_EXPIRY_HOURS);
        registration.resend_count += 1;
        self.state.registration_repo.update(&registration).await?;

        // Trigger Keycloak email verification
        let kc_id = registration.keycloak_id.as_deref().ok_or_else(|| {
            AppError::Internal("No Keycloak ID associated with this record".into())
        })?;

        self.state
            .keycloak_client
            .send_verification_email(kc_id)
            .await
            .map_err(|e| AppError::Keycloak(e.to_string()))?;

        Ok(())
    }
}
