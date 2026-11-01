# ADR-004: Agent Orchestration

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owners:** Portfolio maintainers

## Context

The application coordinates multiple activities:

- Ticket classification.
- Information retrieval.
- Policy assessment.
- Suggested response generation.
- Approval handling.
- Error handling and escalation.

The portfolio compares three implementation approaches while preserving the same application behavior.

## Decision Drivers

- Predictable workflow execution.
- Clear separation between LLM reasoning and deterministic rules.
- Traceable execution state.
- Error handling.
- Human approval support.
- Technology-specific implementation comparison.

## Considered Options

### Option A: Fully autonomous LLM agent

Advantages:
- Flexible tool selection.
- Less explicit workflow code.
- Can handle open-ended tasks.

Disadvantages:
- Harder to predict execution.
- Tool usage may be inconsistent.
- Difficult to enforce deterministic business rules.
- More difficult to audit and evaluate.

### Option B: Deterministic application workflow with LLM-assisted tasks

Advantages:
- Explicit workflow control.
- Business rules remain deterministic.
- Tool authorization is enforced by application code.
- Easier to test and evaluate.
- Human approval can be represented explicitly.

Disadvantages:
- More application workflow code.
- Less flexibility than unrestricted autonomous agents.

### Option C: Framework-managed orchestration

Advantages:
- Provides workflow state and execution features.
- Can simplify persistence and interruption.
- Useful for complex agent workflows.

Disadvantages:
- Introduces framework-specific concepts.
- Requires care to prevent framework coupling.
- Framework behavior must be tested and understood.

## Decision

Adopt **deterministic application-controlled orchestration with LLM-assisted tasks**.

The application controls the workflow. The LLM is used for bounded tasks such as:

- Intent classification.
- Entity extraction.
- Suggested response generation.

The LLM does not control:

- User authorization.
- Tool permissions.
- Refund eligibility.
- Approval state transitions.
- Final business invariants.

### Implementation strategy

| Repository | Orchestration approach |
|---|---|
| `ai-agent-py` | Custom Python orchestrator |
| `ai-agent-lc` | LangGraph workflow implementation |
| `ai-agent-rs` | Rust application workflow |

LangGraph is an implementation choice for `ai-agent-lc`; it is not a shared business requirement.

## Workflow Rules

1. The application determines the allowed next step.
2. LLM output must be validated.
3. Tool operations require application-level authorization.
4. Refund eligibility is deterministic.
5. Sensitive operations require human approval.
6. Failures must produce controlled outcomes.
7. Every execution must have a traceable execution identifier.

## Consequences

### Positive

- Predictable business workflows.
- Clear responsibility boundaries.
- Comparable implementations.
- Easier evaluation and regression testing.
- Reduced risk from unrestricted LLM behavior.

### Negative

- More explicit workflow implementation.
- Each technology stack requires its own orchestration code.
- Complex workflows may require additional state management.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Framework controls business rules | Keep business decisions in domain services and use cases |
| LLM output is incorrectly trusted | Validate all structured output |
| Workflow state becomes inconsistent | Define explicit state transitions and test them |
| Implementations behave differently | Use shared contracts and evaluation datasets |

## Related Decisions

- ADR-002: Modular Monolith
- ADR-003: Clean Architecture
- ADR-005: Human Approval and Shared Evaluation
