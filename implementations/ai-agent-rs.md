# Rust Implementation Plan

**Project:** AI Customer Support & Ticket Resolution Agent  
**Implementation:** `ai-agent-rs`  
**Language:** Rust  
**LLM Framework:** Rig  
**UI Framework:** RustView  
**Architecture:** Modular Monolith + Clean Architecture  
**Status:** Planned

## 1. Purpose

This document defines the technical implementation strategy for the Rust version of the AI Customer Support & Ticket Resolution Agent.

The implementation uses:

- Rig for LLM provider integration and structured model interactions.
- RustView for the browser-based user interface.
- A custom Rust orchestrator for application workflow coordination.
- Rust-native types for domain modeling and business invariants.

The implementation must conform to the shared specifications, domain model, agent contracts, security requirements, guardrail standards, and evaluation protocol.

## 2. Scope

### Included

- Ticket classification.
- Intent and entity extraction.
- Customer, order, and policy lookup.
- Deterministic refund eligibility assessment.
- Rig-based LLM integration.
- Custom agent orchestration.
- Read-only tools.
- Human approval workflow.
- RustView user interface.
- Shared evaluation runner.
- Security, guardrails, and observability.

### Excluded

- Real financial transactions.
- Real customer data.
- Production CRM integrations.
- Autonomous account modifications.
- Unrestricted autonomous tool execution.
- Production database infrastructure in the initial implementation.

## 3. Technology Stack

| Area | Technology |
|---|---|
| Language | Rust |
| Build and package management | Cargo |
| LLM framework | Rig |
| User interface | RustView |
| Serialization | Serde |
| JSON handling | serde_json |
| Async runtime | Tokio |
| HTTP client | Reqwest, where needed outside Rig |
| Error handling | thiserror and anyhow where appropriate |
| Configuration | Environment variables |
| Testing | cargo test |
| Formatting | cargo fmt |
| Linting | Clippy |
| Logging and tracing | tracing and tracing-subscriber |
| Evaluation | Shared JSON datasets and JSON Schema |

Dependency versions must be recorded in `Cargo.toml` and `Cargo.lock`.

Rig and RustView APIs must be verified during implementation setup. Pin compatible versions rather than assuming APIs remain stable.

## 4. Repository Structure

```text
ai-agent-rs/
├── Cargo.toml
├── Cargo.lock
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .env.example
├── .gitignore
│
├── src/
│   ├── main.rs
│   ├── lib.rs
│   │
│   ├── domain/
│   │   ├── entities/
│   │   ├── value_objects/
│   │   ├── enums/
│   │   ├── policies/
│   │   └── errors.rs
│   │
│   ├── application/
│   │   ├── interfaces/
│   │   ├── use_cases/
│   │   ├── orchestrator/
│   │   └── dto/
│   │
│   ├── adapters/
│   │   ├── repositories/
│   │   ├── llm/
│   │   ├── tools/
│   │   ├── approval/
│   │   ├── evaluation/
│   │   ├── ui/
│   │   └── observability/
│   │
│   └── infrastructure/
│       ├── config/
│       ├── logging/
│       └── bootstrap.rs
│
├── data/
│   └── fixtures/
│       ├── customers.json
│       ├── orders.json
│       ├── products.json
│       ├── tickets.json
│       └── business_policies.json
│
├── evaluation/
│   └── README.md
│
├── tests/
│   ├── integration/
│   ├── contract/
│   ├── workflow/
│   ├── security/
│   └── evaluation/
│
└── docs/
    ├── architecture.md
    ├── rig-integration.md
    ├── rustview-integration.md
    ├── experiments.md
    └── decisions.md
```

This is a target logical structure. Rust modules may initially be implemented in fewer files and split as complexity grows.

## 5. Clean Architecture Responsibilities

### 5.1 Entities

Contains framework-independent business concepts.

Examples:

- Customer
- Ticket
- Order
- AgentDecision
- RefundAssessment
- Approval
- BusinessPolicy

Domain services:

- RefundPolicyService
- TicketClassificationPolicy
- ApprovalPolicyService
- TicketEscalationPolicy

Use Rust types to make invalid states difficult to represent.

Examples:

- Enums for finite states.
- Newtypes for identifiers.
- Constructors that enforce invariants.
- Explicit result types for business operations.

The domain layer must not depend on Rig, RustView, HTTP clients, provider SDKs, or JSON repository implementations.

### 5.2 Use Cases

Contains application workflows:

- ProcessTicket
- ClassifyTicket
- ExtractTicketEntities
- RetrieveCustomerContext
- RetrieveOrderContext
- RetrieveBusinessPolicy
- AssessRefundEligibility
- GenerateSuggestedResponse
- RequestApproval
- ReviewApproval

The application layer defines traits for external capabilities it requires.

### 5.3 Interface Adapters

Implements or translates the interfaces required by the application layer.

Examples:

- JSON repositories.
- Rig LLM adapter.
- Read-only tool adapters.
- Approval adapter.
- RustView UI adapter.
- Evaluation dataset loader.
- Observability adapter.

### 5.4 Frameworks and Drivers

Contains technical mechanisms:

- Rig.
- RustView.
- Tokio.
- Reqwest.
- Serde.
- Filesystem access.
- Environment configuration.
- Logging infrastructure.

The UI must call application use cases. It must not implement domain policies or authorization rules.

## 6. Rig Integration Strategy

Rig is the LLM integration framework.

### Responsibilities

- Connect to the selected model provider.
- Configure completion models.
- Submit classification and extraction requests.
- Generate suggested responses.
- Support structured model outputs.
- Handle provider-specific configuration.
- Support asynchronous model interaction.
- Translate provider errors into application-level errors.

### Application-owned interface

Define an application interface similar to:

```rust
#[async_trait::async_trait]
pub trait LlmService: Send + Sync {
    async fn classify_ticket(
        &self,
        input: ClassificationInput,
    ) -> Result<ClassificationOutput, LlmError>;

    async fn extract_entities(
        &self,
        input: ExtractionInput,
    ) -> Result<ExtractionOutput, LlmError>;

    async fn generate_response(
        &self,
        input: ResponseInput,
    ) -> Result<SuggestedResponse, LlmError>;
}
```

The exact signatures will be refined when domain DTOs are implemented.

The Rig adapter implements this interface.

### Structured outputs

Use Serde-compatible types for model output.

Every result must pass:

1. Deserialization.
2. Schema validation where applicable.
3. Semantic validation.
4. Application-level validation.
5. Domain invariant checks.

A successfully deserialized response is not automatically a valid business decision.

### Rig agent and tool execution boundary

Rig supports agents and typed tools. However, this implementation will retain explicit application control over workflow progression.

The initial architecture will use Rig for model interaction and structured output. The custom orchestrator will decide when to invoke application use cases and permitted tools.

Do not allow an LLM-generated tool request to bypass application authorization or resource-scope validation.

Rig's agent loop and additional capabilities can be evaluated experimentally, but they must not replace the authoritative application workflow.

## 7. Custom Agent Orchestration Strategy

Implement a custom Rust orchestrator.

Responsibilities:

1. Validate incoming ticket data.
2. Request classification through the Rig adapter.
3. Extract entities through the Rig adapter.
4. Retrieve authorized customer and order context.
5. Select permitted tools.
6. Execute read-only tools.
7. Call deterministic refund policy services.
8. Generate a suggested response.
9. Validate model output.
10. Determine whether approval is required.
11. Return a recommendation or approval request.

The orchestrator coordinates operations. It does not make authoritative refund policy decisions.

Use explicit workflow state and enums instead of loosely typed dictionaries.

## 8. Rust Type and Error Strategy

### Domain types

Use explicit types for:

- CustomerId
- TicketId
- OrderId
- ExecutionId
- ApprovalId
- Money
- RefundAssessment
- ApprovalStatus
- ExecutionStatus

Represent monetary values using integer minor units or a suitable decimal representation.

For example, CAD 100 is 10,000 minor units.

Do not use floating-point arithmetic for authoritative refund calculations.

### Error handling

Distinguish between:

- Domain errors.
- Application errors.
- Infrastructure errors.
- Rig/provider errors.
- Validation errors.
- Authorization errors.

Use typed errors where callers need to make decisions.

Avoid exposing raw infrastructure errors directly to the UI.

## 9. Data and Repository Strategy

Use synthetic JSON fixtures for initial development.

Repository traits belong to the application layer. JSON-backed implementations belong to the adapter layer.

Initial repositories:

- CustomerRepository
- OrderRepository
- TicketRepository
- BusinessPolicyRepository

Initial repositories are read-only.

Future database persistence must not require domain-layer changes.

## 10. Human Approval Strategy

Use an in-memory approval adapter initially.

Requirements:

- Approval request references the recommendation.
- Reviewer identity comes from application security context.
- Reviewer authorization is checked independently of the UI.
- Separation of duties is enforced.
- Rejected approvals cannot authorize recommendations.
- Invalid approval records fail safely.

The approval interface must support a future persistent implementation.

In-memory state is not durable across process restarts.

## 11. RustView Integration Strategy

RustView provides the browser-based demonstration interface.

### Responsibilities

The UI should support:

- Ticket submission.
- Classification and extracted entity display.
- Retrieved customer and order context.
- Refund assessment explanation.
- Suggested response display.
- Pending approval display.
- Approval and rejection interaction.
- Execution status and safe error messages.

### UI architecture

RustView is an adapter, not the application layer.

Its event handlers should invoke application use cases through the configured application boundary.

The UI must not:

- Calculate refund eligibility.
- Authorize tools.
- Decide approval permissions.
- Directly access repository implementation details.
- Treat model output as an authoritative decision.

### Compatibility validation

During repository setup, verify:

- RustView crate version.
- Supported Rust version and edition.
- Widget and state-management APIs.
- Async execution integration.
- Session handling.
- Application startup and shutdown.
- Build and deployment constraints.

RustView is an actively evolving dependency. Pin the validated version and document any breaking API changes.

If a required capability is unavailable, document the limitation and evaluate an alternative UI adapter without changing the domain architecture.

## 12. Security and Guardrails

Enforce:

- Typed input validation.
- Output validation.
- Actor authorization.
- Resource-level authorization.
- Read-only tool allowlisting.
- Customer data isolation.
- Prompt injection defenses.
- Deterministic refund policy.
- Human approval.
- Secret redaction.
- Safe error handling.

Authorization and business policy must be enforced by application/domain logic, never delegated to Rig or the LLM.

## 13. Evaluation Strategy

Consume the shared datasets:

- `synthetic-data.json`
- `classification.json`
- `tool-selection.json`
- `policy-compliance.json`
- `adversarial-cases.json`

Results must conform to:

`evaluation/schemas/evaluation-result.schema.json`

Follow:

`evaluation/evaluation-protocol.md`

Record:

- Implementation ID.
- Rust version.
- Rig version.
- RustView version.
- Dependency versions.
- Dataset version.
- Model/provider configuration.
- Policy version.
- Reference date.
- Git commit.
- Execution metadata.

Compare results against both Python implementations using the same test cases and acceptance criteria.

## 14. Testing Strategy

| Test level | Purpose |
|---|---|
| Unit | Domain rules, constructors and use cases |
| Integration | JSON repositories, Rig adapter and tools |
| Contract | Shared schemas and serialized contracts |
| Workflow | Orchestration and approval transitions |
| Security | Authorization, data isolation and policy bypass |
| Evaluation | Shared benchmark datasets |
| E2E | RustView and complete application workflow |

Required checks:

```bash
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

Tests must cover refund policy boundaries, approval separation of duties, unauthorized tools, cross-customer access, malformed model responses, and provider failures.

Rig integration tests should use deterministic test doubles where possible. Do not require live model calls for ordinary unit tests.

## 15. Observability

Use structured tracing.

Correlation identifiers:

- request_id
- execution_id
- ticket_id
- trace_id
- tool_execution_id
- approval_id

Record workflow lifecycle, tool execution, model latency, policy outcomes, approval transitions, and failures.

Do not record secrets or unnecessary sensitive content.

## 16. Implementation Sequence

1. Cargo repository setup.
2. Rust quality tooling.
3. Domain entities and value objects.
4. Domain policies and invariants.
5. Application interfaces and DTOs.
6. JSON repositories.
7. Rig integration and provider abstraction.
8. Classification and extraction.
9. Custom orchestrator.
10. Read-only tools.
11. Guardrails and validation.
12. Security and authorization.
13. Human approval workflow.
14. RustView interface.
15. Shared evaluation runner.
16. Observability.
17. Integration and E2E tests.
18. Deployment and documentation.

## 17. Risks and Trade-offs

| Decision | Benefit | Trade-off |
|---|---|---|
| Rig | Unified model integration and structured outputs | Framework dependency and version management |
| RustView | Rust-native browser UI | API maturity and compatibility validation required |
| Custom orchestrator | Full workflow control | More implementation and testing responsibility |
| Rust | Strong type safety | More explicit modeling and ownership complexity |
| JSON fixtures | Simple reproducible test environment | No production persistence or concurrent write support |
| In-memory approval | Simple first implementation | State disappears on restart |
| Async runtime | Efficient I/O concurrency | Requires explicit async design |

## 18. Acceptance Criteria

- [ ] Repository structure documented.
- [ ] Clean Architecture boundaries defined.
- [ ] Domain types and error strategy documented.
- [ ] Rig integration responsibilities defined.
- [ ] Rig adapter implements an application-owned interface.
- [ ] Custom orchestration responsibilities defined.
- [ ] RustView UI responsibilities documented.
- [ ] RustView compatibility validation requirements identified.
- [ ] JSON repository strategy defined.
- [ ] Approval lifecycle documented.
- [ ] Security and guardrail responsibilities documented.
- [ ] Shared evaluation datasets and contracts referenced.
- [ ] Testing and observability strategies documented.
- [ ] Implementation sequence and trade-offs recorded.

## 19. Relationship to Shared Specifications

This implementation must conform to the authoritative documents in `ai-agent-shared`:

- `specifications/02-requirements.md`
- `specifications/04-domain-model.md`
- `specifications/05-agent-contracts.md`
- `specifications/06-architecture.md`
- `engineering/guardrails/`
- `engineering/security/`
- `engineering/evaluation/`
- `engineering/testing/test-strategy.md`
- `evaluation/evaluation-protocol.md`

Resolve conflicts through the shared specifications or approved architecture decisions. Do not silently change shared contracts.

---

**Status:** Planned  
**Implementation starts:** Step 66  
**Next review:** Before implementation begins
