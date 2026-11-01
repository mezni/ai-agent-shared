# Plain Python Implementation Plan

**Project:** AI Customer Support & Ticket Resolution Agent  
**Implementation:** `ai-agent-py`  
**Language:** Python  
**UI:** Streamlit  
**Architecture:** Modular Monolith + Clean Architecture  
**Status:** Planned

## 1. Purpose

This document defines the implementation strategy for the plain Python version of the AI Customer Support & Ticket Resolution Agent.

The objective is to build an understandable, testable, and maintainable agent without relying on an agent framework.

The implementation must conform to the shared specifications, domain model, agent contracts, guardrail standards, security requirements, and evaluation protocol maintained in `ai-agent-shared`.

## 2. Scope

### Included

- Ticket classification.
- Intent and entity extraction.
- Customer lookup.
- Order lookup.
- Business policy lookup.
- Deterministic refund eligibility assessment.
- Suggested response generation.
- Human approval workflow.
- Tool execution controls.
- Input and output validation.
- Evaluation against shared datasets.
- Structured logging and execution correlation.
- Streamlit user interface.

### Excluded

- Real financial transactions.
- Real customer information.
- Production CRM or order management integrations.
- Autonomous account modifications.
- Unrestricted autonomous tool execution.
- Database infrastructure in the initial implementation.
- LangChain and LangGraph.

## 3. Technology Stack

| Area | Technology |
|---|---|
| Language | Python |
| Package manager | uv |
| User interface | Streamlit |
| Data validation | Pydantic |
| LLM integration | Provider SDK behind an application-owned abstraction |
| Data source | Synthetic JSON fixtures |
| Testing | pytest |
| Coverage | pytest-cov |
| Linting | Ruff |
| Schema validation | JSON Schema validator |
| Logging | Python logging with structured JSON output |
| Tracing | Correlation IDs initially; OpenTelemetry-compatible design |
| Configuration | Environment variables and typed settings |

Dependencies must be added only when needed. The LLM provider must remain replaceable without changing domain policies or use cases.

## 4. Repository Structure

```text
ai-agent-py/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── pyproject.toml
├── uv.lock
├── .env.example
├── .gitignore
│
├── app/
│   └── streamlit_app.py
│
├── src/
│   └── ai_agent_py/
│       ├── __init__.py
│       │
│       ├── domain/
│       │   ├── entities/
│       │   ├── value_objects/
│       │   ├── enums/
│       │   ├── policies/
│       │   └── exceptions.py
│       │
│       ├── application/
│       │   ├── interfaces/
│       │   ├── use_cases/
│       │   ├── orchestrator/
│       │   └── dto/
│       │
│       ├── adapters/
│       │   ├── repositories/
│       │   ├── llm/
│       │   ├── tools/
│       │   ├── approval/
│       │   ├── evaluation/
│       │   └── observability/
│       │
│       └── infrastructure/
│           ├── config/
│           ├── logging/
│           └── bootstrap.py
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
│   ├── unit/
│   ├── integration/
│   ├── contract/
│   ├── workflow/
│   ├── security/
│   ├── evaluation/
│   └── e2e/
│
└── docs/
    ├── architecture.md
    ├── experiments.md
    └── decisions.md
```

The directory structure is a target layout. Files and subdirectories will be introduced incrementally as their implementation steps are reached.

## 5. Clean Architecture Responsibilities

### 5.1 Entities

Contains business concepts and invariants.

Examples:

- Customer
- Ticket
- Order
- AgentDecision
- RefundAssessment
- Approval
- BusinessPolicy

Domain policies include:

- RefundPolicyService
- TicketClassificationPolicy
- ApprovalPolicyService
- TicketEscalationPolicy

The domain must not import Streamlit, provider SDKs, repository implementations, or infrastructure modules.

### 5.2 Use Cases

Contains application workflows.

Planned use cases:

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
- ExecuteReadOnlyTool

The application layer defines the interfaces it requires from external capabilities.

### 5.3 Interface Adapters

Translates between application/domain models and external representations.

Examples:

- JSON customer repository.
- JSON order repository.
- LLM provider adapter.
- Tool adapters.
- Approval repository adapter.
- Evaluation dataset loader.
- Structured logging adapter.

Adapters implement the interfaces defined by the inner layers.

### 5.4 Frameworks and Drivers

Provides technical mechanisms.

Examples:

- Streamlit.
- Python runtime.
- Filesystem.
- Environment configuration.
- LLM provider SDK.
- pytest and Ruff.

The Streamlit interface must call application use cases. It must not implement refund policy, authorization, or agent orchestration itself.

## 6. Agent Orchestration

The custom orchestrator coordinates the application workflow.

```text
Ticket Input
     |
     v
Input Validation
     |
     v
Ticket Classification
     |
     v
Entity Extraction
     |
     v
Context Retrieval
     |
     v
Tool Authorization
     |
     v
Read-only Tool Execution
     |
     v
Deterministic Policy Assessment
     |
     v
Suggested Response Generation
     |
     v
Output Validation
     |
     v
Human Approval (when required)
     |
     v
Final Recommendation
```

The orchestrator coordinates operations; it does not become the authority for business policy.

The LLM proposes classifications, extracts information, selects among permitted tool options, and drafts responses. Application logic validates these proposals. Deterministic domain services make authoritative refund eligibility decisions.

## 7. LLM Integration Strategy

Define an application-owned LLM interface.

Responsibilities:

- Generate structured classification results.
- Extract ticket entities.
- Generate suggested responses.
- Return structured results that can be validated.
- Handle provider errors and timeouts.
- Support bounded retries where appropriate.

The domain and use cases must not depend directly on a specific provider SDK.

Provider credentials must be loaded from environment configuration. Never commit actual secrets.

## 8. Data and Repository Strategy

The initial implementation uses synthetic JSON fixtures.

Repository interfaces are defined in the application layer. JSON-backed implementations live in the adapter layer.

Required repositories:

- CustomerRepository
- OrderRepository
- TicketRepository
- BusinessPolicyRepository

The initial repositories are read-only.

This allows a future database implementation without changing the domain model or application workflows.

## 9. Human Approval Strategy

The initial implementation uses an in-memory approval adapter.

Requirements:

- Approval records identify the recommendation being reviewed.
- Reviewer identity comes from the application security context.
- The reviewer must have the required permission.
- A user cannot approve their own sensitive recommendation.
- Rejected or invalid approval cannot authorize the recommendation.
- Approval status is validated by application logic.

The approval interface must allow a future persistent implementation. In-memory approval state is not durable and resets when the application process restarts.

## 10. Security and Guardrails

The implementation must enforce:

- Input schema validation.
- Output schema and semantic validation.
- Authenticated actor context, even in the local demonstration.
- Role-based and resource-level authorization.
- Read-only tool allowlisting.
- Customer and order ownership checks.
- Prompt injection defenses.
- Deterministic policy enforcement.
- Approval requirements.
- Secret redaction in logs.
- Safe failure for invalid or unavailable operations.

LLM instructions are not a security boundary. Authorization and policy checks must execute in application code.

## 11. Evaluation Strategy

The implementation consumes the shared datasets from `ai-agent-shared`:

- `synthetic-data.json`
- `classification.json`
- `tool-selection.json`
- `policy-compliance.json`
- `adversarial-cases.json`

Evaluation results must conform to:

`evaluation/schemas/evaluation-result.schema.json`

The implementation must follow:

`evaluation/evaluation-protocol.md`

The evaluation runner must record implementation identity, dataset version, model/provider configuration, policy version, reference date, commit, and execution metadata.

Critical policy and security failures block acceptance regardless of aggregate scores.

## 12. Testing Strategy

| Test level | Purpose |
|---|---|
| Unit | Domain rules and individual use cases |
| Integration | JSON repositories, LLM adapter, and tool adapters |
| Contract | Shared contracts and JSON Schema |
| Workflow | Complete ticket-processing workflows |
| Security | Authorization, injection, data isolation, approval bypass |
| Evaluation | Shared benchmark datasets |
| E2E | Streamlit application workflows |

Required quality checks:

```bash
uv run pytest
uv run pytest --cov=ai_agent_py --cov-report=term-missing
uv run ruff check .
uv run ruff format --check .
```

## 13. Observability

Every execution should support correlation through:

- request_id
- execution_id
- ticket_id
- trace_id
- tool_execution_id
- approval_id

Capture:

- Execution lifecycle events.
- Classification and extraction outcomes.
- Tool selection and execution status.
- Policy assessment results.
- Approval transitions.
- LLM errors and latency.
- Safe failure events.

Never log secrets or unnecessary sensitive content.

## 14. Implementation Sequence

The Python implementation will follow these steps:

1. Repository and package setup.
2. Development tooling and quality gates.
3. Domain entities and value objects.
4. Domain policies and invariants.
5. Application interfaces and DTOs.
6. JSON-backed repositories.
7. LLM provider abstraction and adapter.
8. Classification and extraction use cases.
9. Custom agent orchestrator.
10. Read-only tools.
11. Guardrails and validation.
12. Security and authorization.
13. Human approval workflow.
14. Streamlit interface.
15. Shared evaluation runner.
16. Observability.
17. Integration and end-to-end tests.
18. Local deployment and documentation.

The detailed implementation will be refined as each step is completed.

## 15. Risks and Trade-offs

| Decision | Benefit | Trade-off |
|---|---|---|
| Custom orchestration | Understand agent internals; full control | More implementation responsibility |
| JSON fixtures | Simple and reproducible | Not suitable for concurrent production use |
| In-memory approval | Easy initial implementation | State is lost on restart |
| Provider abstraction | Easier provider replacement | Additional interface and adapter code |
| Streamlit | Fast demonstration UI | Not a production frontend architecture |
| No database initially | Lower setup complexity | Limited persistence and concurrency |
| No agent framework | Framework-independent learning | More orchestration and state-management code |

## 16. Acceptance Criteria

The implementation plan is ready when:

- [ ] Repository structure is defined.
- [ ] Clean Architecture responsibilities are documented.
- [ ] Source dependencies point inward.
- [ ] Streamlit remains outside the application and domain layers.
- [ ] Custom orchestration responsibilities are defined.
- [ ] LLM provider abstraction is specified.
- [ ] JSON fixture and repository strategy is specified.
- [ ] Human approval limitations are documented.
- [ ] Security and guardrail requirements are mapped.
- [ ] Shared evaluation datasets and contracts are referenced.
- [ ] Testing and observability strategies are defined.
- [ ] Implementation order is documented.
- [ ] Risks and trade-offs are explicit.

## 17. Relationship to Shared Specifications

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

If implementation details conflict with shared specifications, resolve the conflict in the shared specifications or through an approved architecture decision record. Do not silently change shared contracts.

---

**Status:** Planned  
**Implementation starts:** Step 38  
**Next review:** Before implementation begins
