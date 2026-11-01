# LangChain + LangGraph Implementation Plan

**Project:** AI Customer Support & Ticket Resolution Agent  
**Implementation:** `ai-agent-lc`  
**Language:** Python  
**Frameworks:** LangChain + LangGraph  
**UI:** Streamlit  
**Architecture:** Modular Monolith + Clean Architecture  
**Status:** Planned

## 1. Purpose

This document defines the implementation strategy for the LangChain and LangGraph version of the AI Customer Support & Ticket Resolution Agent.

The implementation must satisfy the same shared specifications and evaluation requirements as `ai-agent-py` and `ai-agent-rs`.

The primary learning objective is to understand how a framework-based agent manages model interaction, tools, workflow state, conditional transitions, and human approval.

## 2. Scope

### Included

- Ticket classification and entity extraction.
- LangChain-based LLM integration.
- Structured model outputs.
- Read-only tool integration.
- LangGraph workflow orchestration.
- Explicit workflow state.
- Conditional graph transitions.
- Human approval using LangGraph interrupt/resume.
- Deterministic refund eligibility assessment.
- Streamlit interface.
- Shared dataset evaluation.
- Security, guardrails, and observability.

### Excluded

- Real financial transactions.
- Real customer data.
- Production CRM integrations.
- Autonomous account modifications.
- Unrestricted autonomous tools.
- Production database infrastructure in the initial implementation.

## 3. Technology Stack

| Area | Technology |
|---|---|
| Language | Python |
| Package management | uv |
| LLM framework | LangChain |
| Workflow orchestration | LangGraph |
| Model integration | LangChain model interface and provider adapter |
| Structured output | Pydantic |
| UI | Streamlit |
| Initial data | Synthetic JSON fixtures |
| State/checkpointing | In-memory initially |
| Testing | pytest, pytest-cov |
| Code quality | Ruff |
| Evaluation | Shared JSON datasets and JSON Schema |
| Logging | Structured Python logging |
| Tracing | OpenTelemetry-compatible instrumentation |

Use compatible, pinned dependency versions. Record the actual versions in `uv.lock` and validate framework APIs during implementation.

## 4. Repository Structure

```text
ai-agent-lc/
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
│   └── ai_agent_lc/
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
│       │   └── dto/
│       │
│       ├── adapters/
│       │   ├── repositories/
│       │   ├── llm/
│       │   ├── tools/
│       │   ├── graph/
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
    ├── graph-workflow.md
    ├── experiments.md
    └── decisions.md
```

This is the target layout. Create directories and files incrementally during implementation.

## 5. Clean Architecture Responsibilities

### 5.1 Entities

Contains framework-independent domain models and business invariants.

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

Domain modules must not import LangChain, LangGraph, Streamlit, provider SDKs, or infrastructure adapters.

### 5.2 Use Cases

Coordinates application-specific workflows.

Examples:

- ProcessTicket
- ClassifyTicket
- ExtractTicketEntities
- RetrieveCustomerContext
- RetrieveOrderContext
- AssessRefundEligibility
- GenerateSuggestedResponse
- RequestApproval
- ReviewApproval

The application layer defines the interfaces it needs. Framework-specific implementations remain outside it.

### 5.3 Interface Adapters

Contains implementations that translate between application models and framework or infrastructure representations.

Examples:

- LangChain model adapter.
- LangChain tool adapters.
- LangGraph workflow adapter.
- JSON repository adapters.
- Approval checkpoint adapter.
- Evaluation adapters.
- Observability adapters.

LangGraph state must be translated to and from application DTOs at the appropriate boundary.

### 5.4 Frameworks and Drivers

Provides the technical mechanisms:

- LangChain.
- LangGraph.
- Streamlit.
- Python runtime.
- Filesystem.
- Provider SDK.
- Environment configuration.
- Testing and quality tools.

## 6. LangChain Integration Strategy

LangChain is used for model interaction.

Responsibilities:

- Configure model providers.
- Manage prompts and structured model output.
- Support ticket classification.
- Extract ticket entities.
- Generate suggested responses.
- Integrate approved tool interfaces.
- Handle provider timeouts and failures.

The application layer must depend on an application-owned interface, not directly on a LangChain model class.

Provider-specific details must be isolated in the adapter layer.

LLM-generated data must be validated before it reaches domain operations.

## 7. LangGraph Orchestration Strategy

LangGraph manages the ticket-processing workflow.

### Planned graph nodes

| Node | Responsibility |
|---|---|
| validate_input | Validate incoming ticket data |
| classify_ticket | Determine proposed ticket intent |
| extract_entities | Extract relevant entities |
| retrieve_context | Retrieve customer, order and policy context |
| select_tools | Select permitted read-only tools |
| execute_tools | Execute authorized tools |
| assess_policy | Call deterministic domain policy service |
| generate_response | Draft a suggested response |
| validate_output | Validate response structure and evidence |
| request_approval | Create an approval request |
| complete | Produce final recommendation |
| reject_recommendation | Record rejected recommendation |

### Graph transitions

The graph must support:

- Normal progression.
- Conditional tool execution.
- Clarification requests.
- Unsupported action rejection.
- Safe failure.
- Human approval.
- Approval rejection.
- Workflow resumption.

### State design

The graph state should contain only the information required to coordinate the workflow.

Proposed state fields:

- `execution_id`
- `ticket_id`
- `actor_context`
- `ticket_input`
- `classification`
- `extracted_entities`
- `customer_context`
- `order_context`
- `policy_context`
- `tool_requests`
- `tool_results`
- `refund_assessment`
- `suggested_response`
- `approval_request`
- `approval_result`
- `errors`
- `execution_status`

Avoid placing secrets or unnecessary customer information in graph state.

Domain entities should not be replaced by graph-state dictionaries. Translate between representations at the adapter boundary.

## 8. Human Approval and Checkpointing

Use LangGraph interrupt/resume to pause the workflow when approval is required.

Expected lifecycle:

1. Workflow determines that approval is required.
2. Application validates the approval requirement.
3. Workflow creates an approval request.
4. Graph execution is interrupted.
5. Streamlit displays the pending recommendation.
6. An authorized reviewer submits an approval decision.
7. Application validates reviewer authorization and separation of duties.
8. The graph resumes with the validated decision.
9. Workflow completes or rejects the recommendation.

The approval decision must be validated by application logic. A value supplied directly by the LLM or an untrusted UI input cannot authorize an action.

Use an in-memory checkpointer initially for local development. Document that state is not durable across process restarts. A persistent checkpointer can be considered later without changing domain policy.

## 9. Tool Integration Strategy

Initial read-only tools:

- customer_lookup
- order_lookup
- business_policy_lookup

Refund eligibility assessment is a deterministic domain operation, not an LLM-authoritative tool decision.

Tool requirements:

- Explicit allowlist.
- Strict argument schemas.
- Actor authorization.
- Customer and resource scope checks.
- Timeouts.
- Structured results.
- Error handling.
- Tool execution audit events.

Never rely on a model's decision to enforce tool permissions.

## 10. Data and Repository Strategy

Use the shared synthetic JSON fixtures.

Repository interfaces belong to the application layer. JSON implementations belong to the adapter layer.

Initial repositories:

- CustomerRepository
- OrderRepository
- TicketRepository
- BusinessPolicyRepository

The initial implementation is read-only. No production database is required.

## 11. Guardrails and Policy Enforcement

The implementation must enforce:

- Input validation.
- Structured output validation.
- Prompt injection defenses.
- Tool allowlisting.
- Actor authorization.
- Resource-level authorization.
- Deterministic refund policy.
- Approval separation of duties.
- Safe failure.
- Sensitive-data redaction.

The graph controls workflow progression, but deterministic domain and application logic remain authoritative for policy and security decisions.

## 12. Evaluation Strategy

Consume the shared datasets:

- `synthetic-data.json`
- `classification.json`
- `tool-selection.json`
- `policy-compliance.json`
- `adversarial-cases.json`

Produce results conforming to:

`evaluation/schemas/evaluation-result.schema.json`

Follow:

`evaluation/evaluation-protocol.md`

Record model/provider, prompt version, framework versions, dataset version, policy version, reference date, commit, and execution metadata.

Compare results with `ai-agent-py` using the same datasets, policies, and evaluation protocol.

## 13. Testing Strategy

| Test level | Purpose |
|---|---|
| Unit | Domain services and use cases |
| Integration | LangChain adapters, repositories and tools |
| Contract | Shared JSON schemas and DTO contracts |
| Workflow | Graph paths, state transitions and interrupts |
| Security | Authorization, injection and approval bypass |
| Evaluation | Shared benchmark datasets |
| E2E | Streamlit and complete workflow |

Important workflow cases:

- Successful order inquiry.
- Refund request within the return window.
- Refund exceeding the CAD 100 cap.
- Damaged goods without verification.
- Approval required.
- Approval rejected.
- Unauthorized tool request.
- Cross-customer access attempt.
- Prompt injection in retrieved content.
- Model/provider failure.

## 14. Observability

Record:

- `request_id`
- `execution_id`
- `ticket_id`
- `trace_id`
- `span_id`
- `tool_execution_id`
- `approval_id`

Capture graph node transitions, tool execution status, model latency, policy decisions, approval transitions, retries, and failures.

Do not log secrets or unnecessary sensitive content.

## 15. Implementation Sequence

1. Repository and package setup.
2. Development tooling.
3. Domain entities and value objects.
4. Domain policies.
5. Application interfaces and DTOs.
6. JSON repositories.
7. LangChain model adapter.
8. Classification and extraction.
9. LangChain tool adapters.
10. LangGraph state definition.
11. LangGraph workflow construction.
12. Guardrails and validation.
13. Security and authorization.
14. Human approval interrupt/resume.
15. Streamlit interface.
16. Shared evaluation runner.
17. Observability.
18. Integration and E2E tests.
19. Deployment and documentation.

## 16. Risks and Trade-offs

| Decision | Benefit | Trade-off |
|---|---|---|
| LangChain | Standardized model integration | Framework abstraction and version dependencies |
| LangGraph | Explicit stateful workflows | Additional state and graph complexity |
| In-memory checkpointing | Simple local setup | No durable recovery across restarts |
| JSON fixtures | Reproducible synthetic data | No production concurrency |
| Streamlit | Fast demonstration UI | Limited production frontend capabilities |
| Framework isolation | Preserves Clean Architecture | Requires translation and adapter code |

## 17. Acceptance Criteria

- [ ] Target repository structure documented.
- [ ] Clean Architecture boundaries defined.
- [ ] Domain remains independent of LangChain and LangGraph.
- [ ] LangChain responsibilities documented.
- [ ] LangGraph nodes, state and transitions documented.
- [ ] Approval interrupt/resume workflow defined.
- [ ] Tool authorization enforced outside the LLM.
- [ ] Deterministic policy enforcement preserved.
- [ ] Shared datasets and evaluation contract referenced.
- [ ] Security, testing and observability requirements documented.
- [ ] Risks and trade-offs identified.
- [ ] Implementation sequence documented.

## 18. Relationship to Shared Specifications

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

Resolve specification conflicts through the shared repository and approved architecture decisions. Do not silently modify shared contracts.

---

**Status:** Planned  
**Implementation starts:** Step 53  
**Next review:** Before implementation begins
