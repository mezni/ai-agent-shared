#!/bin/bash

set -e

echo "Generating infrastructure layer..."

cd auth-service

# Create infrastructure directories for missing modules
mkdir -p src/infrastructure/{database,auth,audit}

# Database
cat > src/infrastructure/database.rs << 'EOF'
use async_trait::async_trait;
use sqlx::{postgres::PgPoolOptions, PgPool};
use uuid::Uuid;

use crate::domain::entities::{User, Company, AuditLog};
use crate::domain::enums::{UserRole, AuditAction};
use crate::domain::repositories::{UserRepository, CompanyRepository, AuditLogRepository};
use crate::domain::errors::DomainError;
use crate::infrastructure::errors::InfrastructureError;

pub type DatabasePool = PgPool;

pub async fn create_pool(config: &crate::infrastructure::config::DatabaseConfig) -> Result<DatabasePool, InfrastructureError> {
    PgPoolOptions::new()
        .max_connections(config.max_connections)
        .connect(&config.connection_string())
        .await
        .map_err(|e| InfrastructureError::PoolError(e.to_string()))
}

pub struct UserRepositoryImpl {
    pool: DatabasePool,
}

impl UserRepositoryImpl {
    pub fn new(pool: DatabasePool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl UserRepository for UserRepositoryImpl {
    async fn create(&self, user: &User) -> Result<User, DomainError> {
        let row = sqlx::query(
            r#"
            INSERT INTO users (id, keycloak_id, username, email, role, company_id, email_verified, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING id, keycloak_id, username, email, role, company_id, email_verified, created_at, updated_at
            "#,
        )
        .bind(user.id)
        .bind(&user.keycloak_id)
        .bind(&user.username)
        .bind(&user.email)
        .bind(user.role.to_string())
        .bind(user.company_id)
        .bind(user.email_verified)
        .bind(user.created_at)
        .bind(user.updated_at)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(User {
            id: row.get("id"),
            keycloak_id: row.get("keycloak_id"),
            username: row.get("username"),
            email: row.get("email"),
            role: row.get::<String, _>("role").parse().map_err(|e: String| DomainError::InvalidUserRole(e))?,
            company_id: row.get("company_id"),
            email_verified: row.get("email_verified"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
    }
    
    async fn find_by_id(&self, id: Uuid) -> Result<Option<User>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM users WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn find_by_keycloak_id(&self, keycloak_id: &str) -> Result<Option<User>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM users WHERE keycloak_id = $1
            "#,
        )
        .bind(keycloak_id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn find_by_email(&self, email: &str) -> Result<Option<User>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM users WHERE email = $1
            "#,
        )
        .bind(email)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn find_by_username(&self, username: &str) -> Result<Option<User>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM users WHERE username = $1
            "#,
        )
        .bind(username)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn update(&self, user: &User) -> Result<User, DomainError> {
        let row = sqlx::query(
            r#"
            UPDATE users 
            SET username = $2, email = $3, role = $4, company_id = $5, email_verified = $6, updated_at = $7
            WHERE id = $1
            RETURNING id, keycloak_id, username, email, role, company_id, email_verified, created_at, updated_at
            "#,
        )
        .bind(user.id)
        .bind(&user.username)
        .bind(&user.email)
        .bind(user.role.to_string())
        .bind(user.company_id)
        .bind(user.email_verified)
        .bind(chrono::Utc::now())
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(User {
            id: row.get("id"),
            keycloak_id: row.get("keycloak_id"),
            username: row.get("username"),
            email: row.get("email"),
            role: row.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: row.get("company_id"),
            email_verified: row.get("email_verified"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
    }
    
    async fn delete(&self, id: Uuid) -> Result<(), DomainError> {
        sqlx::query(
            r#"
            DELETE FROM users WHERE id = $1
            "#,
        )
        .bind(id)
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(())
    }
    
    async fn list_by_company(&self, company_id: Uuid) -> Result<Vec<User>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM users WHERE company_id = $1
            "#,
        )
        .bind(company_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }).collect())
    }
    
    async fn list_all(&self) -> Result<Vec<User>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM users
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| User {
            id: r.get("id"),
            keycloak_id: r.get("keycloak_id"),
            username: r.get("username"),
            email: r.get("email"),
            role: r.get::<String, _>("role").parse().unwrap_or(UserRole::User),
            company_id: r.get("company_id"),
            email_verified: r.get("email_verified"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }).collect())
    }
}

pub struct CompanyRepositoryImpl {
    pool: DatabasePool,
}

impl CompanyRepositoryImpl {
    pub fn new(pool: DatabasePool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl CompanyRepository for CompanyRepositoryImpl {
    async fn create(&self, company: &Company) -> Result<Company, DomainError> {
        let row = sqlx::query(
            r#"
            INSERT INTO companies (id, name, description, created_by, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id, name, description, created_by, created_at, updated_at
            "#,
        )
        .bind(company.id)
        .bind(&company.name)
        .bind(&company.description)
        .bind(company.created_by)
        .bind(company.created_at)
        .bind(company.updated_at)
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(Company {
            id: row.get("id"),
            name: row.get("name"),
            description: row.get("description"),
            created_by: row.get("created_by"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
    }
    
    async fn find_by_id(&self, id: Uuid) -> Result<Option<Company>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM companies WHERE id = $1
            "#,
        )
        .bind(id)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| Company {
            id: r.get("id"),
            name: r.get("name"),
            description: r.get("description"),
            created_by: r.get("created_by"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn find_by_name(&self, name: &str) -> Result<Option<Company>, DomainError> {
        let row = sqlx::query(
            r#"
            SELECT * FROM companies WHERE name = $1
            "#,
        )
        .bind(name)
        .fetch_optional(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(row.map(|r| Company {
            id: r.get("id"),
            name: r.get("name"),
            description: r.get("description"),
            created_by: r.get("created_by"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }))
    }
    
    async fn update(&self, company: &Company) -> Result<Company, DomainError> {
        let row = sqlx::query(
            r#"
            UPDATE companies 
            SET name = $2, description = $3, updated_at = $4
            WHERE id = $1
            RETURNING id, name, description, created_by, created_at, updated_at
            "#,
        )
        .bind(company.id)
        .bind(&company.name)
        .bind(&company.description)
        .bind(chrono::Utc::now())
        .fetch_one(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(Company {
            id: row.get("id"),
            name: row.get("name"),
            description: row.get("description"),
            created_by: row.get("created_by"),
            created_at: row.get("created_at"),
            updated_at: row.get("updated_at"),
        })
    }
    
    async fn delete(&self, id: Uuid) -> Result<(), DomainError> {
        sqlx::query(
            r#"
            DELETE FROM companies WHERE id = $1
            "#,
        )
        .bind(id)
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(())
    }
    
    async fn list_all(&self) -> Result<Vec<Company>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM companies
            "#,
        )
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| Company {
            id: r.get("id"),
            name: r.get("name"),
            description: r.get("description"),
            created_by: r.get("created_by"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }).collect())
    }
    
    async fn list_by_user(&self, user_id: Uuid) -> Result<Vec<Company>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT c.* FROM companies c
            LEFT JOIN users u ON u.company_id = c.id
            WHERE u.id = $1 OR c.created_by = $1
            "#,
        )
        .bind(user_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| Company {
            id: r.get("id"),
            name: r.get("name"),
            description: r.get("description"),
            created_by: r.get("created_by"),
            created_at: r.get("created_at"),
            updated_at: r.get("updated_at"),
        }).collect())
    }
}

pub struct AuditLogRepositoryImpl {
    pool: DatabasePool,
}

impl AuditLogRepositoryImpl {
    pub fn new(pool: DatabasePool) -> Self {
        Self { pool }
    }
}

#[async_trait]
impl AuditLogRepository for AuditLogRepositoryImpl {
    async fn create(&self, audit_log: &AuditLog) -> Result<(), DomainError> {
        sqlx::query(
            r#"
            INSERT INTO audit_logs (id, user_id, action, resource_type, resource_id, details, ip_address, user_agent, created_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            "#,
        )
        .bind(audit_log.id)
        .bind(audit_log.user_id)
        .bind(audit_log.action.to_string())
        .bind(&audit_log.resource_type)
        .bind(&audit_log.resource_id)
        .bind(&audit_log.details)
        .bind(&audit_log.ip_address)
        .bind(&audit_log.user_agent)
        .bind(audit_log.created_at)
        .execute(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(())
    }
    
    async fn find_by_user(&self, user_id: Uuid) -> Result<Vec<AuditLog>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM audit_logs WHERE user_id = $1 ORDER BY created_at DESC
            "#,
        )
        .bind(user_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| AuditLog {
            id: r.get("id"),
            user_id: r.get("user_id"),
            action: r.get::<String, _>("action").parse().unwrap_or(AuditAction::Login),
            resource_type: r.get("resource_type"),
            resource_id: r.get("resource_id"),
            details: r.get("details"),
            ip_address: r.get("ip_address"),
            user_agent: r.get("user_agent"),
            created_at: r.get("created_at"),
        }).collect())
    }
    
    async fn find_by_company(&self, company_id: Uuid) -> Result<Vec<AuditLog>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT al.* FROM audit_logs al
            LEFT JOIN users u ON al.user_id = u.id
            WHERE u.company_id = $1
            ORDER BY al.created_at DESC
            "#,
        )
        .bind(company_id)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| AuditLog {
            id: r.get("id"),
            user_id: r.get("user_id"),
            action: r.get::<String, _>("action").parse().unwrap_or(AuditAction::Login),
            resource_type: r.get("resource_type"),
            resource_id: r.get("resource_id"),
            details: r.get("details"),
            ip_address: r.get("ip_address"),
            user_agent: r.get("user_agent"),
            created_at: r.get("created_at"),
        }).collect())
    }
    
    async fn list_recent(&self, limit: u32) -> Result<Vec<AuditLog>, DomainError> {
        let rows = sqlx::query(
            r#"
            SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT $1
            "#,
        )
        .bind(limit as i32)
        .fetch_all(&self.pool)
        .await
        .map_err(|e| DomainError::ValidationError(e.to_string()))?;
        
        Ok(rows.into_iter().map(|r| AuditLog {
            id: r.get("id"),
            user_id: r.get("user_id"),
            action: r.get::<String, _>("action").parse().unwrap_or(AuditAction::Login),
            resource_type: r.get("resource_type"),
            resource_id: r.get("resource_id"),
            details: r.get("details"),
            ip_address: r.get("ip_address"),
            user_agent: r.get("user_agent"),
            created_at: r.get("created_at"),
        }).collect())
    }
}
EOF

# Keycloak Auth
cat > src/infrastructure/auth.rs << 'EOF'
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::infrastructure::config::KeycloakConfig;
use crate::infrastructure::errors::InfrastructureError;

#[derive(Debug, Clone)]
pub struct KeycloakClient {
    config: KeycloakConfig,
    http_client: Client,
}

impl KeycloakClient {
    pub fn new(config: KeycloakConfig) -> Self {
        Self {
            config,
            http_client: Client::new(),
        }
    }
    
    pub async fn create_user(&self, username: &str, email: &str, password: &str) -> Result<String, InfrastructureError> {
        let admin_token = self.get_admin_token().await?;
        
        let user_data = serde_json::json!({
            "username": username,
            "email": email,
            "enabled": true,
            "emailVerified": false,
            "credentials": [{
                "type": "password",
                "value": password,
                "temporary": false
            }]
        });
        
        let response = self.http_client
            .post(&self.config.admin_users_url())
            .header("Authorization", format!("Bearer {}", admin_token))
            .header("Content-Type", "application/json")
            .json(&user_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            // Extract user ID from location header
            if let Some(location) = response.headers().get("Location") {
                if let Ok(location_str) = location.to_str() {
                    if let Some(user_id) = location_str.split('/').last() {
                        return Ok(user_id.to_string());
                    }
                }
            }
            Err(InfrastructureError::KeycloakError("Failed to extract user ID from response".to_string()))
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("Keycloak API error: {}", error_text)))
        }
    }
    
    pub async fn login(&self, username: &str, password: &str) -> Result<KeycloakTokenResponse, InfrastructureError> {
        let mut form_data = HashMap::new();
        form_data.insert("grant_type", "password");
        form_data.insert("client_id", &self.config.client_id);
        form_data.insert("client_secret", &self.config.client_secret);
        form_data.insert("username", username);
        form_data.insert("password", password);
        
        let response = self.http_client
            .post(&self.config.token_url())
            .header("Content-Type", "application/x-www-form-urlencoded")
            .form(&form_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            let token_response: KeycloakTokenResponse = response.json().await?;
            Ok(token_response)
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("Login failed: {}", error_text)))
        }
    }
    
    pub async fn refresh_token(&self, refresh_token: &str) -> Result<KeycloakTokenResponse, InfrastructureError> {
        let mut form_data = HashMap::new();
        form_data.insert("grant_type", "refresh_token");
        form_data.insert("client_id", &self.config.client_id);
        form_data.insert("client_secret", &self.config.client_secret);
        form_data.insert("refresh_token", refresh_token);
        
        let response = self.http_client
            .post(&self.config.token_url())
            .header("Content-Type", "application/x-www-form-urlencoded")
            .form(&form_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            let token_response: KeycloakTokenResponse = response.json().await?;
            Ok(token_response)
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("Token refresh failed: {}", error_text)))
        }
    }
    
    pub async fn user_info(&self, access_token: &str) -> Result<KeycloakUserInfo, InfrastructureError> {
        let response = self.http_client
            .get(&self.config.user_info_url())
            .header("Authorization", format!("Bearer {}", access_token))
            .send()
            .await?;
        
        if response.status().is_success() {
            let user_info: KeycloakUserInfo = response.json().await?;
            Ok(user_info)
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("User info request failed: {}", error_text)))
        }
    }
    
    pub async fn update_user(&self, user_id: &str, attributes: HashMap<String, String>) -> Result<(), InfrastructureError> {
        let admin_token = self.get_admin_token().await?;
        
        let user_data = serde_json::json!({
            "attributes": attributes
        });
        
        let response = self.http_client
            .put(&format!("{}/{}", self.config.admin_users_url(), user_id))
            .header("Authorization", format!("Bearer {}", admin_token))
            .header("Content-Type", "application/json")
            .json(&user_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            Ok(())
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("User update failed: {}", error_text)))
        }
    }
    
    pub async fn reset_password(&self, user_id: &str, new_password: &str) -> Result<(), InfrastructureError> {
        let admin_token = self.get_admin_token().await?;
        
        let password_data = serde_json::json!({
            "type": "password",
            "value": new_password,
            "temporary": false
        });
        
        let response = self.http_client
            .put(&format!("{}/{}/reset-password", self.config.admin_users_url(), user_id))
            .header("Authorization", format!("Bearer {}", admin_token))
            .header("Content-Type", "application/json")
            .json(&password_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            Ok(())
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("Password reset failed: {}", error_text)))
        }
    }
    
    async fn get_admin_token(&self) -> Result<String, InfrastructureError> {
        let mut form_data = HashMap::new();
        form_data.insert("grant_type", "password");
        form_data.insert("client_id", &self.config.client_id);
        form_data.insert("client_secret", &self.config.client_secret);
        form_data.insert("username", &self.config.admin_username);
        form_data.insert("password", &self.config.admin_password);
        
        let response = self.http_client
            .post(&self.config.admin_token_url())
            .header("Content-Type", "application/x-www-form-urlencoded")
            .form(&form_data)
            .send()
            .await?;
        
        if response.status().is_success() {
            let token_response: KeycloakTokenResponse = response.json().await?;
            Ok(token_response.access_token)
        } else {
            let error_text = response.text().await.unwrap_or_default();
            Err(InfrastructureError::KeycloakError(format!("Admin token request failed: {}", error_text)))
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeycloakTokenResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub expires_in: i64,
    pub token_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeycloakUserInfo {
    pub sub: String,
    pub email: String,
    pub preferred_username: String,
    pub email_verified: bool,
    pub exp: i64,
    pub iat: i64,
}
EOF

# Audit
cat > src/infrastructure/audit.rs << 'EOF'
use async_trait::async_trait;

use crate::domain::entities::AuditLog;
use crate::domain::repositories::AuditLogRepository;
use crate::domain::errors::DomainError;

pub struct AuditService {
    audit_repository: Box<dyn AuditLogRepository>,
}

impl AuditService {
    pub fn new(audit_repository: Box<dyn AuditLogRepository>) -> Self {
        Self { audit_repository }
    }
    
    pub async fn log_event(
        &self,
        user_id: Option<uuid::Uuid>,
        action: crate::domain::enums::AuditAction,
        resource_type: String,
        resource_id: Option<String>,
        details: Option<serde_json::Value>,
        ip_address: Option<String>,
        user_agent: Option<String>,
    ) -> Result<(), DomainError> {
        let audit_log = AuditLog::new(
            user_id,
            action,
            resource_type,
            resource_id,
            details,
            ip_address,
            user_agent,
        );
        
        self.audit_repository.create(&audit_log).await
    }
}
EOF

# Create database migrations
mkdir -p migrations
cat > migrations/001_initial_schema.sql << 'EOF'
-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    keycloak_id VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Admin', 'Partner', 'Operator', 'User', 'Guest')),
    company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create audit_logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(255),
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_companies_created_by ON companies(created_by);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EOF

echo "Infrastructure layer generated successfully!"