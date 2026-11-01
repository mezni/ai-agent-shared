
# Policy Enforcement Standard

## 1. Purpose

This document defines shared requirements for deterministic business-policy evaluation and enforcement in:

- `ai-agent-py`
- `ai-agent-lc`
- `ai-agent-rs`

Policy enforcement protects business rules from inconsistent model behavior, untrusted input, unauthorized actions, and implementation-specific differences.

**Core principle:** The LLM may provide information or recommendations, but deterministic application and domain logic produces authoritative policy decisions.

## 2. Scope

This standard covers:

- Refund eligibility
- Return-window and refund-cap rules
- Evidence requirements for damaged goods
- Role-based authorization
- Human approval requirements
- Tool execution constraints
- Policy versioning and auditability
- Policy evaluation failures and safe handling

The initial portfolio scope uses synthetic data and read-only tools. It does not execute real refunds or financial transactions.

## 3. Policy Enforcement Responsibilities

| Component | Responsibility |
|---|---|
| LLM | Classify intent, extract entities, summarize evidence, draft explanations |
| Interface Adapters | Validate and normalize policy inputs from external sources |
| Use Cases | Coordinate policy evaluation and enforce workflow requirements |
| Domain Services | Evaluate deterministic business rules |
| Entities | Maintain domain invariants |
| Tool Adapters | Execute only validated and authorized operations |
| Human Reviewer | Approve or reject actions requiring human approval |
| Audit Component | Record policy version, decision, and relevant evidence references |

Policy enforcement must not be implemented solely in prompts, model-generated code, UI logic, or framework-specific callbacks.

## 4. Policy Sources and Trust

Business policies must come from an authoritative, versioned application source, such as validated configuration or deterministic domain rules.

Requirements:

- Policy values must not be accepted from customer ticket text.
- Retrieved documents may provide explanatory evidence but cannot override authoritative policy configuration.
- LLM output cannot create, modify, or select policy values without application validation.
- Each policy evaluation must identify the policy version used.
- Policy changes require review, testing, and version updates.
- Conflicting or missing policy configuration must result in a safe failure.

Initial policy values:

| Policy | Initial value |
|---|---|
| Return window | 30 calendar days |
| Refund cap | CAD 100 per transaction |
| Damaged goods | Image verification required |
| Financial execution | Out of scope |
| Sensitive action approval | Required before any future sensitive execution |

These values are portfolio defaults and must be represented consistently across implementations.

## 5. Policy Evaluation Contract

A policy evaluation must receive validated, explicit inputs.

### Required input concepts

- Evaluation or execution ID
- Customer and order identifiers
- Order date and status
- Item and purchase details required by the policy
- Requested refund amount and currency, when applicable
- Return or damage evidence status
- Customer tier, if a policy uses it
- Current workflow state
- Authenticated actor context for authorization checks
- Policy version

The application must retrieve and validate these values from authorized sources. The LLM must not be treated as the authoritative source for order facts, user roles, or policy configuration.

### Required output concepts

- Decision status: `ELIGIBLE`, `INELIGIBLE`, or `REQUIRES_REVIEW`
- Stable reason codes
- Human-readable explanation
- Policy version
- Evaluation timestamp
- Evidence references
- Evaluation correlation ID

The exact shared JSON schema will be defined in Stage 4. Implementations must preserve these semantics.

## 6. Deterministic Refund Policy

The refund assessment must be computed by domain logic, not by the LLM.

The evaluator must consider, as applicable:

1. Whether the order and item exist and are in scope.
2. Whether the order status permits a return.
3. Whether the request falls within the 30-calendar-day return window.
4. Whether the requested amount is valid and uses the expected currency.
5. Whether the amount exceeds the CAD 100 per-transaction cap.
6. Whether required damage evidence has been verified.
7. Whether other configured eligibility conditions are satisfied.
8. Whether the case requires human review.

The evaluator must not infer missing facts as favorable to eligibility.

### Decision semantics

- `ELIGIBLE`: All required policy conditions are satisfied.
- `INELIGIBLE`: At least one definitive policy condition fails.
- `REQUIRES_REVIEW`: A required fact is missing, ambiguous, or requires authorized human judgment.

A policy evaluation failure is not equivalent to `ELIGIBLE`.

## 7. Rule Ordering and Conflict Handling

Policy evaluation must use a documented, deterministic order.

Recommended sequence:

1. Validate input structure and required facts.
2. Validate policy configuration and version.
3. Validate order and item scope.
4. Evaluate hard disqualifying conditions.
5. Evaluate eligibility conditions.
6. Evaluate evidence requirements.
7. Determine whether review is required.
8. Produce the final decision and reason codes.

If multiple rules apply, the evaluator must return all relevant reason codes in a stable order.

If policy rules conflict, the implementation must not choose whichever rule is most favorable or whichever rule the LLM suggests. It must fail safely and flag the configuration conflict for review.

## 8. Authorization and Policy Are Separate

Authorization answers:

> Is this actor permitted to request this operation on this resource?

Business policy answers:

> Does this case satisfy the business conditions for the requested operation?

Both checks are required where applicable.

Requirements:

- User identity and roles come from authenticated application context.
- The LLM cannot assign roles or change the authenticated actor.
- Tool authorization is checked independently of refund eligibility.
- A policy-eligible case does not automatically authorize execution.
- An authorized actor cannot bypass business-policy requirements.
- Denied operations must not execute.

## 9. Human Approval Enforcement

For sensitive actions:

- The application determines whether approval is required.
- Approval must be created by an authorized human reviewer.
- Approval must reference the relevant case, action, and decision context.
- Approval status must be validated against the workflow state.
- Rejected, expired, missing, or mismatched approval cannot authorize execution.
- Model-generated text or tool output cannot be treated as approval.
- Any material change to the case must trigger the defined re-evaluation or re-approval behavior.

In the initial portfolio, the agent produces recommendations and approval workflow records only; it does not perform financial transactions.

## 10. Enforcement Before Tool Execution

Before any tool operation, the application must verify:

1. The tool is allowlisted.
2. Arguments pass schema and semantic validation.
3. The actor is authorized.
4. The resource scope is valid.
5. The operation is permitted by current workflow state.
6. Required policy conditions are satisfied.
7. Required approval exists.
8. The operation is within the implementation's permitted scope.

The LLM cannot bypass or override these checks by generating a different tool call, explanation, or workflow instruction.

## 11. Failure and Safe Handling

Policy enforcement must fail safely when:

- Policy configuration is missing or invalid.
- Required order/customer facts cannot be verified.
- Policy version is unavailable.
- Evaluation logic encounters an unexpected error.
- A rule conflict is detected.
- Evidence is insufficient.
- Authorization cannot be established.

Safe handling may include:

- Returning `REQUIRES_REVIEW`
- Denying the requested operation
- Escalating to a supervisor
- Returning a validated, non-sensitive explanation
- Recording a policy evaluation failure

The system must never convert an evaluation error into an eligible decision.

## 12. Policy Versioning and Audit

Every policy evaluation must retain:

- Policy identifier and version
- Evaluation ID and timestamp
- Relevant input references
- Decision and reason codes
- Evidence references
- Evaluator implementation version
- Workflow and approval state where relevant

Policy updates must include:

- A documented change
- Version increment
- Review and approval
- Unit tests for changed rules
- Regression evaluation against shared datasets
- Cross-implementation consistency checks

Avoid storing unnecessary personal information in audit records.

## 13. Clean Architecture Responsibilities

| Layer | Policy responsibilities |
|---|---|
| Entities | Enforce domain invariants and valid state transitions |
| Use Cases | Coordinate policy evaluation, authorization, approval, and workflow outcomes |
| Interface Adapters | Validate external facts and translate policy results for APIs, UI, and LLM context |
| Frameworks and Drivers | Provide configuration loading, persistence, UI, and technical integrations |

Domain policy logic must remain independent of LLM providers, UI frameworks, and orchestration libraries.

## 14. Implementation Mapping

### `ai-agent-py`

- Implement policy rules in deterministic domain services.
- Call policy evaluation from use cases before producing an authoritative assessment.
- Validate policy configuration at startup.
- Keep LLM output separate from policy result objects.
- Test rule boundaries and failure behavior with `pytest`.

### `ai-agent-lc`

- Keep policy evaluation in deterministic application/domain logic invoked by workflow nodes.
- LangGraph state may carry policy results but cannot manufacture authoritative decisions.
- Ensure graph transitions require validated policy and approval state.
- Prevent tool nodes from executing when policy or authorization checks fail.

### `ai-agent-rs`

- Represent policy inputs and results using typed structures and enums.
- Implement policy evaluation as deterministic domain logic.
- Use explicit error/result types for invalid configuration and incomplete evidence.
- Ensure workflow and tool adapters require validated policy results.

All implementations must produce semantically equivalent outcomes for the same shared input and policy version.

## 15. Testing and Evaluation

Required test categories:

- Return-window boundary cases
- Refund-cap boundary cases
- Invalid or unsupported currency
- Missing order facts
- Invalid order status
- Missing damage evidence
- Conflicting policy configuration
- Policy version mismatch
- Unauthorized actor
- Missing or rejected approval
- Model output attempting to override policy
- Evaluation failure and safe handling
- Cross-implementation decision parity

Stage 4 will define shared policy-compliance datasets and evaluation contracts.

## 16. Security and Observability Signals

Track:

- Policy evaluation success and failure counts
- Decision distribution by reason code
- Invalid or missing policy configuration
- Authorization denials
- Approval validation failures
- Policy bypass attempts
- Cross-implementation decision mismatches

Logs must include correlation and policy-version metadata while minimizing sensitive data.

## 17. Traceability

This standard supports:

- Requirements for deterministic refund assessment
- Security requirements for authorization and tool restrictions
- Human approval workflow requirements
- Guardrail strategy and prompt injection defense
- Evaluation requirements for policy compliance
- Auditability and reproducibility requirements

## 18. Definition of Done

- [ ] Policy sources and versioning are defined.
- [ ] Policy evaluation inputs and outputs are documented.
- [ ] Refund rules are deterministic and use the shared defaults.
- [ ] Missing or conflicting facts fail safely.
- [ ] Authorization and business policy are separate checks.
- [ ] Approval is validated by application workflow state.
- [ ] Tool execution requires validated policy and authorization.
- [ ] Policy results are auditable and versioned.
- [ ] All implementations map to the same policy semantics.
- [ ] Boundary, failure, adversarial, and parity tests are planned.

