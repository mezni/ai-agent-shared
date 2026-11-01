# Testing Strategy

## 1. Purpose

This document defines the shared testing strategy for the AI Customer Support & Ticket Resolution Agent.

It establishes how the project verifies:

- Functional correctness.
- Domain invariants.
- Agent contracts.
- Workflow behavior.
- Business policy compliance.
- Security and authorization.
- LLM output quality.
- Operational reliability.
- Cross-implementation consistency.

The strategy applies to:

- `ai-agent-py`
- `ai-agent-lc`
- `ai-agent-rs`

## 2. Testing Principles

1. Test business rules independently of frameworks and LLM providers.
2. Prefer deterministic tests for deterministic behavior.
3. Test application behavior through defined contracts.
4. Use synthetic fixtures exclusively.
5. Isolate external dependencies in unit tests.
6. Test failures and unauthorized operations, not only successful paths.
7. Use shared datasets for comparable agent evaluations.
8. Preserve reproducibility through versioned datasets and configurations.
9. Treat security and policy bypasses as release-blocking failures.
10. Require equivalent business behavior across all implementations.

## 3. Testing Scope

Testing covers:

| Area | What must be verified |
|---|---|
| Domain | Entities, invariants, and business rules |
| Application | Use cases and workflow orchestration |
| Infrastructure | Repositories, LLM adapters, and external integrations |
| Contracts | Request, response, and tool schemas |
| Agent behavior | Classification, extraction, and tool selection |
| Policies | Deterministic refund and approval decisions |
| Security | Authentication, authorization, isolation, and data protection |
| UI | User interactions and approval presentation |
| Observability | Logs, traces, metrics, and correlation |
| Evaluation | Quality, reliability, and regression |
| Parity | Equivalent business behavior across implementations |

## 4. Testing Levels

### 4.1 Unit tests

Verify an individual function, class, or domain behavior in isolation.

Examples:

- Ticket classification rules.
- Refund eligibility calculation.
- Return-window calculation.
- Refund cap enforcement.
- Approval policy.
- Input validation.
- Output validation.
- Authorization decisions.

Unit tests must not require a live LLM provider, database, or external service.

### 4.2 Integration tests

Verify that multiple components work together correctly.

Examples:

- Use case with repository implementation.
- Agent orchestrator with deterministic tools.
- LLM adapter with a mocked provider.
- Tool adapter with a synthetic data source.
- Workflow state persistence, if implemented.
- Observability instrumentation with application events.

Integration tests should use controlled dependencies.

### 4.3 Contract tests

Verify that components conform to shared interface and data contracts.

Examples:

- Ticket input schema.
- Classification output schema.
- Refund assessment schema.
- Tool request and response schemas.
- Approval request and decision schemas.
- Error response schema.
- Evaluation result schema.

The shared repository is the authoritative source for these contracts.

### 4.4 Workflow tests

Verify complete agent workflows.

Examples:

- Order-status inquiry.
- Refund request within the return window.
- Refund request outside the return window.
- Refund amount above the cap.
- Damaged-item request requiring image verification.
- Request requiring human approval.
- Rejected approval.
- Tool failure during order lookup.
- LLM failure during response generation.

Workflow tests must verify the final outcome and important intermediate transitions.

### 4.5 Security tests

Verify that the system enforces security requirements.

Examples:

- Unauthorized resource access.
- Cross-customer data access.
- Role escalation.
- Tool authorization bypass.
- Prompt injection attempts.
- Secret exposure.
- Approval bypass.
- Sensitive information in logs.
- Unsafe export behavior.

Security tests must include negative cases.

### 4.6 Evaluation tests

Evaluate model-dependent behavior using versioned datasets.

Examples:

- Ticket classification.
- Entity extraction.
- Tool selection.
- Response quality.
- Evidence support.
- Adversarial robustness.

Evaluation tests are distinct from ordinary unit tests because their outputs may vary with model behavior.

### 4.7 End-to-end tests

Verify the system from its user interface or public application entry point through the final workflow outcome.

Examples:

- Submit a ticket through the UI.
- Review the generated assessment.
- Request approval.
- Record an approval decision.
- Display the final response.

E2E tests should use synthetic data and controlled external dependencies.

## 5. Test Pyramid

The project should follow a test pyramid:

1. Many unit tests.
2. A substantial set of integration and contract tests.
3. Focused workflow and security tests.
4. A smaller number of end-to-end tests.
5. Dataset-based evaluations executed as a separate quality gate.

The pyramid is a planning principle, not a fixed numerical ratio.

Fast deterministic tests should provide the majority of routine development feedback.

## 6. Test Environment Strategy

### Unit environment

- No network access required.
- No real LLM calls.
- No production services.
- Deterministic fixtures.
- Controlled clocks when time affects business rules.

### Integration environment

- Synthetic repositories.
- Mocked or local external dependencies.
- Controlled LLM responses.
- Temporary storage when required.

### Evaluation environment

- Versioned shared datasets.
- Explicit model and provider configuration.
- Recorded evaluation configuration.
- Reproducible scoring logic.
- Controlled execution settings.

### End-to-end environment

- Local application.
- Synthetic data.
- Test user identities and roles.
- Controlled approval workflow.
- No real financial execution.

## 7. Test Data Management

The shared repository owns the common synthetic evaluation datasets.

Implementation-specific tests may add local fixtures, provided they do not contradict shared requirements.

Requirements:

- No real customer data.
- Stable synthetic identifiers.
- Explicit dataset versions.
- Documented expected outcomes.
- Positive and negative cases.
- Boundary conditions.
- Adversarial cases.
- No secrets in test fixtures.

The same logical test cases must be usable across all three implementations.

## 8. Test Doubles

Use test doubles to isolate dependencies.

| Test double | Purpose |
|---|---|
| Dummy | Supplies an unused placeholder |
| Stub | Returns predefined data |
| Fake | Provides a simplified working implementation |
| Mock | Verifies expected interactions |
| Spy | Records calls for later assertions |

Examples:

- Fake customer repository.
- Stub order lookup tool.
- Mock LLM provider.
- Spy observability recorder.
- Fake approval repository.

Use mocks selectively. Prefer testing observable behavior over internal implementation details.

## 9. Domain Testing

Domain tests must verify business invariants independently of the agent framework.

### Refund policy

The shared initial rules are:

- Return window: 30 calendar days.
- Maximum refund amount: CAD 100 per transaction.
- Damaged goods: image verification required.

Required test cases include:

- Eligible request within the return window.
- Request at the return-window boundary.
- Request outside the return window.
- Refund amount at the cap.
- Refund amount above the cap.
- Damaged item with verification evidence.
- Damaged item without verification evidence.
- Missing required order information.
- Failed policy evaluation.

The deterministic policy service is authoritative.

The LLM must never determine or override refund eligibility.

### Approval policy

Verify:

- Approval is required when the applicable policy says so.
- The requester cannot approve their own sensitive recommendation.
- A rejected approval cannot authorize the action.
- Approval requires an authorized reviewer.
- An approval decision is associated with the correct execution.
- Missing or invalid approval fails safely.

## 10. Agent Behavior Testing

### Classification

Verify:

- Correct intent.
- Correct category.
- Appropriate handling of ambiguous requests.
- Unknown or unsupported intent handling.

### Entity extraction

Verify:

- Order identifiers.
- Ticket identifiers.
- Relevant product or item information.
- Missing entities.
- Invalid entity formats.

### Tool selection

Verify:

- Correct tool selected for the intent.
- Required arguments supplied.
- Unsupported tools rejected.
- Unauthorized operations denied.
- Unnecessary tools not invoked.

### Response generation

Verify:

- Response is consistent with the deterministic assessment.
- Claims are supported by retrieved evidence.
- No fabricated order or policy details.
- No unsupported promises.
- Correct handling of missing information.
- Safe response when dependencies fail.

## 11. Security and Adversarial Testing

The shared adversarial dataset must cover:

- Prompt injection in ticket content.
- Malicious instructions in retrieved content.
- Attempts to retrieve another customer's information.
- Attempts to bypass authorization.
- Attempts to override refund policy.
- Attempts to bypass human approval.
- Attempts to reveal secrets.
- Malformed tool arguments.
- Unexpected LLM output.
- Repeated or excessive tool execution attempts.

Expected behavior must be defined for each case.

Critical security failures block acceptance.

## 12. Evaluation Testing

Evaluation tests use the shared datasets and evaluation protocol.

Required evaluation categories:

- Classification.
- Entity extraction.
- Tool selection.
- Policy compliance.
- Response quality.
- Adversarial robustness.

The authoritative thresholds are defined in:

`engineering/evaluation/metrics.md`

Initial acceptance thresholds include:

| Metric | Target |
|---|---:|
| Classification accuracy | ≥ 90% |
| Classification macro F1 | ≥ 0.85 |
| Entity field accuracy | ≥ 95% |
| Entity exact match | ≥ 85% |
| Tool selection accuracy | ≥ 95% |
| Invalid executed tool calls | 0% |
| Policy decision accuracy | 100% |
| Policy bypass | 0% |
| Approval bypass | 0% |
| Response quality | ≥ 4.0 / 5 |
| Evidence support | ≥ 95% |
| Sensitive data exposure | 0% |
| Critical safe-failure cases | 100% |
| Accepted output schema validity | 100% |
| Cross-implementation policy parity | 100% |

A test run must record:

- Dataset version.
- Evaluation run identifier.
- Implementation.
- Model provider and model identifier, where applicable.
- Configuration.
- Execution timestamp.
- Metric results.
- Failed case identifiers.

## 13. Regression Testing

Previously identified defects must become regression tests.

Requirements:

- Add a test for every fixed defect when practical.
- Preserve failed evaluation cases.
- Re-run relevant tests after policy or prompt changes.
- Compare results against the previous accepted baseline.
- Investigate unexpected quality regressions.
- Do not silently update expected results to make a failing test pass.

Changes to shared requirements or expected outcomes must be reviewed and versioned.

## 14. Cross-Implementation Parity Testing

The three implementations must use the same logical inputs and expected business outcomes.

Parity testing must cover:

- Domain invariants.
- Refund eligibility.
- Approval requirements.
- Authorization outcomes.
- Tool contracts.
- Error behavior.
- Agent output contracts.
- Evaluation dataset interpretation.

Different frameworks may produce different internal execution structures.

They must nevertheless produce equivalent authoritative business decisions.

For example:

A refund request outside the 30-calendar-day return window must not become eligible in one implementation simply because it uses a different LLM framework.

Policy parity is mandatory.

## 15. Failure Injection and Resilience Testing

The system must be tested under controlled failure conditions.

Examples:

- LLM provider unavailable.
- LLM timeout.
- Malformed model response.
- Repository failure.
- Tool timeout.
- Invalid tool result.
- Missing approval record.
- Invalid authorization context.
- Observability exporter unavailable.

Expected behavior:

- Fail safely.
- Do not fabricate successful results.
- Do not bypass policy enforcement.
- Do not execute unauthorized actions.
- Preserve useful diagnostic information without exposing sensitive data.

Observability failure must not silently disable authorization or policy enforcement.

## 16. Performance Testing

Performance testing will be introduced after functional correctness and a stable local baseline exist.

Potential measurements:

- End-to-end execution latency.
- Classification latency.
- Retrieval latency.
- Tool execution latency.
- LLM latency.
- Memory consumption.
- Concurrent request behavior.

Performance thresholds remain open until representative workloads are measured.

Do not optimize against invented baseline measurements.

## 17. UI Testing

The Streamlit and RustView applications must be tested for:

- Ticket submission.
- Input validation.
- Loading and error states.
- Display of classification and assessment.
- Display of supporting evidence.
- Approval request presentation.
- Approval and rejection flows.
- Prevention of unauthorized actions.
- Clear distinction between suggested and approved outcomes.

The interface must never present an unapproved recommendation as an executed financial action.

## 18. Test Automation and CI

The CI pipeline should execute quality gates in increasing cost order:

1. Formatting and linting.
2. Unit tests.
3. Contract tests.
4. Integration tests.
5. Security and static checks.
6. Workflow tests.
7. Shared evaluation tests.
8. Build and packaging checks.

Long-running or provider-dependent evaluations may run in a dedicated CI job.

Pull requests must not be accepted when critical policy, authorization, or security tests fail.

Each implementation maintains its own CI pipeline while consuming shared specifications and datasets.

## 19. Clean Architecture Testing Responsibilities

| Layer | Testing focus |
|---|---|
| Entities | Invariants and domain behavior |
| Use Cases | Application workflows and authorization decisions |
| Interface Adapters | Contract translation, validation, and mapping |
| Frameworks and Drivers | External integrations and framework behavior |

Domain tests should not require framework initialization.

The Dependency Rule remains unchanged: source-code dependencies point inward.

## 20. Cross-Implementation Tooling

| Implementation | Recommended testing tools |
|---|---|
| Python | pytest, pytest-cov, Ruff |
| LangChain/LangGraph | pytest, pytest-cov, framework-specific test utilities |
| Rust | cargo test, cargo fmt, Clippy |
| Shared evaluation | Versioned JSON datasets and shared evaluation schemas |
| API contract | JSON Schema validation and contract tests |
| CI | GitHub Actions or an equivalent CI platform |

Tool selection may evolve, but shared acceptance criteria remain authoritative.

## 21. Test Reporting

Every test or evaluation run should report:

- Implementation name.
- Test suite.
- Execution timestamp.
- Total tests.
- Passed tests.
- Failed tests.
- Skipped tests.
- Failure details.
- Dataset version, when applicable.
- Evaluation metrics, when applicable.

Reports must not include secrets or unnecessary personal information.

## 22. Definition of Done

- [ ] Testing principles are documented.
- [ ] Testing scope covers all application layers.
- [ ] Unit testing requirements are defined.
- [ ] Integration and contract testing are defined.
- [ ] Workflow and end-to-end testing are defined.
- [ ] Domain policy tests are specified.
- [ ] Security and adversarial tests are specified.
- [ ] Evaluation testing uses shared datasets and thresholds.
- [ ] Regression testing requirements are documented.
- [ ] Cross-implementation parity is defined.
- [ ] Failure injection requirements are documented.
- [ ] Performance testing approach is defined.
- [ ] UI testing requirements are documented.
- [ ] CI quality gates are defined.
- [ ] Clean Architecture responsibilities are mapped.
- [ ] Python, LangChain/LangGraph, and Rust tooling is identified.

## 23. Traceability

Related standards:

- `specifications/02-requirements.md`
- `specifications/04-domain-model.md`
- `specifications/05-agent-contracts.md`
- `specifications/07-definition-of-done.md`
- `engineering/guardrails/strategy.md`
- `engineering/guardrails/policy-enforcement.md`
- `engineering/security/threat-model.md`
- `engineering/security/authentication-authorization.md`
- `engineering/security/data-protection.md`
- `engineering/observability/strategy.md`
- `engineering/evaluation/strategy.md`
- `engineering/evaluation/metrics.md`

**Status:** Proposed shared testing standard.

**Scope:** Defines common testing and acceptance requirements for all three implementations. Implementation-specific test commands and CI configuration will be created in their respective repositories.
