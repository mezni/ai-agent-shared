# Assumptions and Open Questions

**Project:** AI Customer Support & Ticket Resolution Agent  
**Status:** Initial baseline  
**Applies to:** `ai-agent-py`, `ai-agent-lc`, `ai-agent-rs`  
**Last reviewed:** 2026-11-01

---

## 1. Purpose

This document records confirmed decisions, working assumptions, unresolved questions, and project risks.

Its purpose is to:

- Prevent assumptions from being mistaken for requirements.
- Identify decisions that could affect architecture.
- Make unresolved questions visible before implementation.
- Track risks and mitigation strategies.
- Maintain consistency across the three implementations.

This document must be updated whenever a significant assumption is confirmed, rejected, or replaced.

## 2. Confirmed decisions

The following decisions have been established for the initial portfolio.

| ID | Decision | Status |
|---|---|---|
| CD-001 | Product is an AI Customer Support & Ticket Resolution Agent | Confirmed |
| CD-002 | Three independent implementation repositories will be created | Confirmed |
| CD-003 | Shared specifications are maintained in `ai-agent-shared` | Confirmed |
| CD-004 | Python implementation uses Streamlit | Confirmed |
| CD-005 | LangChain implementation uses LangChain, LangGraph, and Streamlit | Confirmed |
| CD-006 | Rust implementation uses Rust and RustView | Confirmed |
| CD-007 | Architecture style is Modular Monolith + Clean Architecture | Confirmed |
| CD-008 | All implementations follow the shared domain model and agent contracts | Confirmed |
| CD-009 | Initial data is synthetic | Confirmed |
| CD-010 | Refund eligibility is determined by deterministic business rules | Confirmed |
| CD-011 | Sensitive recommendations require human approval | Confirmed |
| CD-012 | Real financial transactions are outside initial scope | Confirmed |
| CD-013 | Initial refund return window is 30 calendar days | Confirmed |
| CD-014 | Initial refund cap is CAD 100 per transaction | Confirmed |
| CD-015 | Damaged goods require image verification | Confirmed |
| CD-016 | Initial customer, order, and policy lookup tools are read-only | Confirmed |
| CD-017 | Shared evaluation datasets and protocols will be used | Confirmed |
| CD-018 | Git-versioned `LOG.md` tracks implementation progress | Confirmed |

These decisions form the initial project baseline. Changes require documentation and, where appropriate, an architecture decision record.

## 3. Working assumptions

The following assumptions are used to move the project forward but have not all been validated against a real support organization.

| ID | Assumption | Why it is needed | Validation |
|---|---|---|---|
| AS-001 | The initial system handles a single ticket per execution | Keeps the first workflow manageable | Review workflow requirements |
| AS-002 | One customer is associated with a ticket | Simplifies initial ticket processing | Validate domain requirements |
| AS-003 | Customer and order IDs are available in synthetic ticket data or can be extracted | Enables lookup workflows | Test synthetic dataset |
| AS-004 | Orders have enough information to evaluate refund eligibility | Enables deterministic assessment | Validate order fixture schema |
| AS-005 | The initial agent supports English-language tickets | Limits initial language complexity | Review evaluation scope |
| AS-006 | The initial application runs as a single deployable application | Fits modular monolith architecture | Revisit deployment requirements |
| AS-007 | Initial persistence can use local adapters and synthetic fixtures | Avoids premature database complexity | Validate implementation needs |
| AS-008 | A configurable LLM provider can satisfy the initial structured-output requirements | Enables provider-independent architecture | Prototype provider integration |
| AS-009 | Human approval can be handled inside the application UI | Avoids an external approval platform | Validate approval workflow |
| AS-010 | A local development identity mechanism is sufficient for initial demonstrations | Avoids production identity integration | Review security tests |
| AS-011 | Evaluation can initially run locally or in CI | Keeps evaluation reproducible | Validate execution time |
| AS-012 | The same business scenarios can be executed across all three implementations | Enables fair comparison | Validate shared fixtures and contracts |

Assumptions must be revisited when implementation evidence contradicts them.

## 4. Open questions

### 4.1 Business and domain questions

| ID | Question | Priority | Impact |
|---|---|---|---|
| OQ-001 | Should tickets support multiple customer languages? | Medium | Classification and response generation |
| OQ-002 | Should one ticket support multiple orders? | Medium | Domain model and entity extraction |
| OQ-003 | How should partial refunds be represented in the initial assessment? | High | Refund domain model |
| OQ-004 | Should refund policy vary by product category? | Medium | Policy model |
| OQ-005 | Should customer membership tier affect refund eligibility? | Medium | Business policy |
| OQ-006 | What conditions should trigger automatic escalation? | High | Workflow and approval rules |
| OQ-007 | Should supervisors have different approval limits from administrators? | Medium | Authorization policy |

**Initial handling:** Keep the first version focused on one ticket, one customer, and the established refund rules. Document additional business scenarios before extending the domain model.

### 4.2 AI and LLM questions

| ID | Question | Priority | Impact |
|---|---|---|---|
| OQ-008 | Which LLM provider should be used? | High | Infrastructure and configuration |
| OQ-009 | Which model should be the default? | High | Cost, quality, latency |
| OQ-010 | Should structured output use provider-native JSON schema support? | Medium | LLM adapter |
| OQ-011 | What fallback behavior should apply when the LLM is unavailable? | High | Reliability |
| OQ-012 | Should a second model be used as a fallback? | Low | Cost and complexity |
| OQ-013 | What confidence threshold should trigger human review? | High | Classification and approval |
| OQ-014 | How should model and prompt versions be recorded? | High | Evaluation and observability |

**Initial handling:** Define a provider-neutral interface. Choose the provider and model during implementation planning and record the decision in an ADR.

### 4.3 Architecture and infrastructure questions

| ID | Question | Priority | Impact |
|---|---|---|---|
| OQ-015 | Is FastAPI required as a separate application boundary? | Medium | Application architecture |
| OQ-016 | Which persistence technology should replace local fixtures if needed? | Medium | Infrastructure |
| OQ-017 | Should execution and approval history survive application restarts? | High | Persistence design |
| OQ-018 | Should the three applications use identical deployment environments? | Medium | Deployment and comparison |
| OQ-019 | Should an external message queue be introduced in a future version? | Low | Workflow architecture |
| OQ-020 | Which tracing implementation should be used? | Medium | Observability |
| OQ-021 | What is the final RustView integration approach? | Medium | Rust presentation layer |

**Initial handling:** Keep the modular monolith. Avoid adding infrastructure until a documented requirement justifies it.

### 4.4 Security questions

| ID | Question | Priority | Impact |
|---|---|---|---|
| OQ-022 | What authentication mechanism should be used beyond local demonstration? | High | Identity |
| OQ-023 | Which role-to-permission matrix should be enforced? | High | Authorization |
| OQ-024 | Should supervisors be allowed to approve their own recommendations? | Medium | Approval governance |
| OQ-025 | How long should audit records be retained? | Medium | Data management |
| OQ-026 | What additional controls are required before any real customer data is introduced? | High | Privacy and security |
| OQ-027 | How should secrets be managed in CI and deployment environments? | Medium | Infrastructure security |

**Initial handling:** Use synthetic data, enforce application-level authorization, and keep production identity and data protection decisions open until separately specified.

### 4.5 Evaluation questions

| ID | Question | Priority | Impact |
|---|---|---|---|
| OQ-028 | What classification accuracy target should be required? | High | Evaluation |
| OQ-029 | What tool-selection success rate is acceptable? | High | Agent reliability |
| OQ-030 | What response-quality evaluation method should be used? | Medium | Evaluation |
| OQ-031 | Which evaluation cases should be considered release blockers? | High | Quality gates |
| OQ-032 | How should latency and token cost be compared fairly? | Medium | Portfolio comparison |
| OQ-033 | Should evaluation include human-reviewed response quality? | Medium | Evaluation methodology |

**Initial handling:** Define the metrics and measurement protocol before setting numerical release thresholds.

## 5. Risk register

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R-001 | Three implementations drift from shared contracts | Medium | High | Shared schemas and contract tests |
| R-002 | LLM generates incorrect business conclusions | High | High | Deterministic domain policy services |
| R-003 | Prompt injection influences agent behavior | Medium | High | Input controls, tool authorization, adversarial evaluations |
| R-004 | Unauthorized tool invocation | Medium | High | Application-controlled authorization |
| R-005 | Invalid model output breaks workflow | Medium | Medium | Structured-output validation and safe failure |
| R-006 | LLM provider becomes unavailable | Medium | High | Timeout handling and controlled fallback |
| R-007 | Sensitive information appears in logs | Medium | High | Data minimization and log sanitization |
| R-008 | Approval workflow permits conflicting decisions | Low | High | State validation and idempotency |
| R-009 | Evaluation metrics create misleading comparisons | Medium | Medium | Shared datasets and identical evaluation protocol |
| R-010 | Architecture becomes unnecessarily complex | Medium | Medium | Modular monolith and documented ADRs |
| R-011 | RustView integration requires architectural changes | Medium | Medium | Isolate presentation technology |
| R-012 | Local persistence loses execution history | Medium | Medium | Explicit persistence requirements and tests |

Risk levels are initial qualitative assessments, not measured probabilities.

## 6. Dependencies and constraints

### 6.1 Project dependencies

The portfolio depends on:

- Shared domain model.
- Shared agent contracts.
- Shared evaluation datasets.
- Shared evaluation protocol.
- Consistent business rules.
- Compatible development environments.
- Reproducible test and build commands.

### 6.2 Technical constraints

- Python implementation must use Python.
- LangChain implementation must use LangChain and LangGraph.
- Rust implementation must use Rust and RustView.
- Each implementation must use Clean Architecture.
- All implementations must support the shared business requirements.
- No real financial transactions are permitted in the initial scope.
- Synthetic data is used for development and demonstration.
- The LLM must not make authoritative refund-policy decisions.
- Application authorization must not be delegated to the LLM.

## 7. Decision ownership and governance

Every open question must eventually have one of these outcomes:

1. **Accepted:** The assumption becomes a confirmed decision.
2. **Rejected:** The assumption is removed and replaced.
3. **Deferred:** The decision is postponed with a documented reason.
4. **Out of scope:** The capability is explicitly excluded.

Significant architectural or technical decisions should be recorded in Architecture Decision Records.

Recommended ADR format:

- Context.
- Decision drivers.
- Options considered.
- Decision.
- Consequences.
- Status.

## 8. Initial decision backlog

The following decisions should be addressed before their corresponding implementation steps.

| Decision | Related work | Target stage |
|---|---|---|
| LLM provider and model | Provider adapter | Implementation planning |
| LLM fallback behavior | Reliability | Implementation planning |
| Confidence and review thresholds | Agent evaluation | Evaluation foundation |
| Evaluation quality thresholds | Evaluation metrics | Evaluation foundation |
| Role-permission matrix | Security | Security standards |
| Authentication approach | Security implementation | Implementation planning |
| Execution persistence | Infrastructure | Implementation planning |
| RustView integration | Rust UI | Rust implementation |
| Tracing implementation | Observability | Observability standards |

## 9. Review policy

Review this document:

- When a business requirement changes.
- When an architectural decision changes.
- When an assumption is disproved.
- When implementation reveals a new constraint.
- Before starting a major implementation stage.
- Before final portfolio publication.

Every change must be reflected in the appropriate specification or ADR.

## 10. Definition of Done

- [ ] Confirmed decisions are documented.
- [ ] Working assumptions are distinguished from confirmed decisions.
- [ ] Open questions are grouped by subject.
- [ ] Questions have priorities and impacts.
- [ ] Initial project risks are recorded.
- [ ] Mitigation strategies are identified.
- [ ] Technical constraints are documented.
- [ ] Decision governance is defined.
- [ ] Decision backlog is established.
- [ ] Document is consistent with the project overview, requirements, domain model, contracts, architecture, and DoD.
- [ ] The document is committed to `ai-agent-shared`.

---

**Next step:** Complete the Stage 1 specification review and move into architecture documentation.
