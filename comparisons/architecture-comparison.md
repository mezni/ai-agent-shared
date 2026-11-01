# Architecture Comparison Methodology

**Portfolio:** AI Customer Support & Ticket Resolution Agent  
**Repository:** `ai-agent-shared`  
**Status:** Planned  
**Implementations:** `ai-agent-py`, `ai-agent-lc`, `ai-agent-rs`

## 1. Purpose

This document defines a repeatable methodology for comparing three implementations of the same AI agent.

The comparison evaluates architectural quality, developer experience, orchestration, reliability, security, functional quality, performance, and maintainability.

The objective is to identify measurable differences and understand the engineering trade-offs associated with each approach.

## 2. Implementations Under Comparison

### Implementation A: Plain Python

- Language: Python.
- LLM integration: Custom provider abstraction.
- Orchestration: Custom Python orchestrator.
- UI: Streamlit.
- Validation: Pydantic.
- Initial storage: Synthetic JSON fixtures.

### Implementation B: LangChain + LangGraph

- Language: Python.
- LLM integration: LangChain.
- Orchestration: LangGraph.
- UI: Streamlit.
- Validation: Pydantic.
- Initial storage: Synthetic JSON fixtures.
- Human approval: LangGraph interrupt/resume.

### Implementation C: Rust + Rig + RustView

- Language: Rust.
- LLM integration: Rig.
- Orchestration: Custom Rust orchestrator.
- UI: RustView.
- Serialization: Serde.
- Initial storage: Synthetic JSON fixtures.
- Async runtime: Tokio.

## 3. Comparison Principles

All implementations must:

1. Implement the same business requirements.
2. Follow the same domain model.
3. Conform to the same agent contracts.
4. Apply the same business policies.
5. Use the same synthetic data.
6. Use the same evaluation datasets and versions.
7. Meet the same security requirements.
8. Follow the same evaluation protocol.
9. Record their dependencies and configuration.
10. Document deviations and limitations.

The implementations may use different internal designs, but observable business behavior must remain equivalent.

## 4. Architecture Comparison

### 4.1 Layer Separation

Evaluate:

- Domain independence.
- Application responsibility boundaries.
- Adapter responsibility boundaries.
- Framework isolation.
- Dependency direction.
- Dependency injection and composition.
- Separation of UI and business logic.

Questions:

- Can domain policies be tested without external infrastructure?
- Can the LLM provider be replaced without changing domain code?
- Can JSON repositories be replaced without changing use cases?
- Does the UI invoke application workflows rather than implementing business logic?
- Are dependencies directed inward?

### 4.2 Modularity

Evaluate:

- Module cohesion.
- Coupling between modules.
- Responsibility clarity.
- Reuse of domain services.
- Ease of introducing new use cases.

### 4.3 Architectural Consistency

Verify that all three implementations follow the shared Modular Monolith and Clean Architecture requirements.

Do not award a higher architecture score merely because a framework provides more abstractions.

## 5. Developer Experience Comparison

Measure:

- Initial repository setup time.
- Time to implement a new use case.
- Time to add a new read-only tool.
- Time to change a domain policy.
- Time to debug a failed workflow.
- Time to add a new evaluation case.
- Dependency management complexity.
- Local development experience.

Record actual development time rather than estimating it after completion.

Qualitative observations should include:

- Learning curve.
- Documentation quality.
- IDE support.
- Compiler and static analysis feedback.
- Error-message quality.
- Debugging experience.

## 6. Agent Orchestration Comparison

Evaluate the implementation of:

- Workflow state.
- State transitions.
- Conditional execution.
- Tool selection.
- Tool execution.
- Retry handling.
- Error recovery.
- Clarification requests.
- Human approval.
- Workflow resumption.

Specific questions:

### Plain Python

- How much orchestration code is required?
- Is workflow state explicit?
- Are transitions easy to test?
- How difficult is workflow recovery?

### LangChain + LangGraph

- How clearly are graph nodes and transitions expressed?
- How effectively does graph state support the workflow?
- How does checkpointing behave?
- How understandable are interrupt/resume operations?
- How much framework-specific code is required?

### Rust + Rig

- How effectively do Rust types model workflow states?
- How easy is it to coordinate asynchronous operations?
- How clearly are Rig interactions isolated?
- How much orchestration code is required?
- How effectively are errors propagated?

Rig and LangGraph are not equivalent orchestration technologies. The comparison evaluates their actual responsibilities rather than assuming they provide identical capabilities.

## 7. Reliability Comparison

Measure:

- Input validation success.
- Output schema validity.
- Invalid state handling.
- Provider failure handling.
- Tool timeout handling.
- Repository failure handling.
- Retry behavior.
- Safe failure behavior.
- Workflow completion rate.

Critical failures include:

- Incorrect authoritative refund decisions.
- Unauthorized tool execution.
- Approval bypass.
- Cross-customer data exposure.
- Invalid policy enforcement.

Any critical policy or security failure blocks acceptance.

## 8. Security Comparison

Evaluate:

- Authentication context handling.
- Role-based authorization.
- Resource-level authorization.
- Customer data isolation.
- Tool allowlisting.
- Tool argument validation.
- Prompt injection resistance.
- Sensitive-data handling.
- Approval separation of duties.
- Auditability.

Use the shared adversarial dataset and security test strategy.

Security results must include both successful defenses and identified weaknesses.

A model refusing a malicious request is not sufficient evidence of security. Application-side enforcement must also be tested.

## 9. Evaluation Quality Comparison

All implementations must use the same benchmark datasets.

| Metric | Initial acceptance target |
|---|---:|
| Classification accuracy | >= 90% |
| Classification macro F1 | >= 0.85 |
| Entity field accuracy | >= 95% |
| Entity exact match | >= 85% |
| Tool selection accuracy | >= 95% |
| Invalid executed tool calls | 0 |
| Policy decision accuracy | 100% |
| Policy bypasses | 0 |
| Approval bypasses | 0 |
| Response quality | >= 4.0 / 5 |
| Evidence support | >= 95% |
| Sensitive data exposure | 0 |
| Critical safe failure | 100% |
| Accepted output schema validity | 100% |
| Policy decision parity | 100% |

The evaluation protocol in `evaluation/evaluation-protocol.md` is authoritative.

Do not change thresholds separately for individual implementations.

## 10. Performance Comparison

Measure:

- End-to-end execution latency.
- Median latency (P50).
- P95 latency.
- P99 latency where sufficient samples exist.
- Throughput.
- Memory consumption.
- CPU utilization.
- Startup time.
- LLM provider latency.
- Tool execution latency.
- Workflow orchestration overhead.

### Measurement controls

To improve fairness:

1. Use the same machine or documented equivalent environments.
2. Use the same synthetic input cases.
3. Use the same model provider and model where supported.
4. Keep prompts and generation settings consistent where possible.
5. Record model and provider versions.
6. Separate model latency from application overhead.
7. Record token usage.
8. Run warm-up tests separately.
9. Run repeated trials.
10. Report distributions, not only averages.

Performance targets will be established after baseline measurements.

## 11. Maintainability Comparison

Evaluate:

- Module complexity.
- Code duplication.
- Testability.
- Dependency coupling.
- Documentation quality.
- Change impact.
- Error handling clarity.
- Ease of adding a new tool.
- Ease of adding a new business policy.
- Ease of replacing the LLM provider.

Use code review and practical change exercises in addition to static metrics.

## 12. Scoring Methodology

Use a 1–5 rating for qualitative dimensions.

| Score | Interpretation |
|---:|---|
| 1 | Poor: major architectural or engineering weaknesses |
| 2 | Limited: significant improvements required |
| 3 | Acceptable: meets baseline requirements |
| 4 | Strong: clear and maintainable implementation |
| 5 | Excellent: well-structured, robust and easy to extend |

Qualitative ratings must include written evidence.

Suggested dimensions:

- Architecture.
- Developer experience.
- Orchestration.
- Reliability.
- Security engineering.
- Maintainability.

Evaluation quality and performance should primarily use measured results rather than subjective ratings.

Do not combine all dimensions into one score that could hide a critical security failure.

## 13. Experimental Controls

For every comparison run, record:

- Implementation ID.
- Git commit SHA.
- Rust or Python version.
- Framework and dependency versions.
- Operating system.
- Hardware configuration.
- LLM provider and model.
- Prompt version.
- Generation settings.
- Dataset ID and version.
- Policy version.
- Reference date.
- Evaluation runner version.
- Execution timestamp.
- Test sample count.

If an implementation deviates from a shared contract, document the deviation and do not treat its results as directly equivalent until resolved.

## 14. Comparison Deliverables

Create and maintain:

- `comparisons/architecture-comparison.md`
- `comparisons/quality-comparison.md`
- `comparisons/performance-comparison.md`
- `comparisons/lessons-learned.md`

This methodology defines the process. Actual results will be added after the three implementations have been built and evaluated.

## 15. Acceptance Criteria

- [ ] All three implementations are documented.
- [ ] Comparison dimensions are defined.
- [ ] Functional and contract parity requirements are defined.
- [ ] Architecture criteria are documented.
- [ ] Orchestration criteria are documented.
- [ ] Reliability and security criteria are documented.
- [ ] Evaluation thresholds reference the shared protocol.
- [ ] Performance measurement controls are defined.
- [ ] Maintainability criteria are documented.
- [ ] Scoring methodology is defined.
- [ ] Experimental metadata requirements are defined.
- [ ] Comparison deliverables are identified.
- [ ] Critical security and policy failures cannot be hidden by aggregate scores.

**Status:** Methodology defined  
**Execution:** After all three implementations are complete
