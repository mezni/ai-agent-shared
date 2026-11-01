# ADR-005: Human Approval and Shared Evaluation

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owners:** Portfolio maintainers

## Context

The AI Support Agent makes recommendations that can affect customers, including refund eligibility assessments and suggested responses.

The portfolio must demonstrate responsible agent design and provide a consistent way to compare the three implementations.

## Decision Drivers

- Human oversight.
- Deterministic business decisions.
- Auditable approval decisions.
- Safe handling of sensitive workflows.
- Comparable agent quality.
- Repeatable evaluation.
- Prevention of implementation-specific evaluation bias.

## Considered Options

### Option A: Fully autonomous resolution

Advantages:
- Less human intervention.
- Potentially faster workflow completion.

Disadvantages:
- Higher risk of incorrect business decisions.
- Reduced human oversight.
- Greater difficulty demonstrating controlled execution.

### Option B: Human approval for sensitive recommendations

Advantages:
- Human oversight at critical decision points.
- Explicit approval and rejection workflow.
- Better auditability.
- Sensitive actions can be held until approval.

Disadvantages:
- Requires an approval interface.
- Adds workflow state and coordination.
- Can increase resolution time.

### Option C: Separate evaluation standards for each implementation

Advantages:
- Technology-specific metrics can be introduced quickly.

Disadvantages:
- Results become difficult to compare.
- Different datasets can produce misleading conclusions.
- Implementation quality can be confused with dataset differences.

### Option D: Shared evaluation datasets and protocol

Advantages:
- Same input cases across implementations.
- Comparable quality measurements.
- Easier regression testing.
- Consistent business-policy validation.

Disadvantages:
- Requires shared dataset maintenance.
- Some framework-specific metrics require additional instrumentation.

## Decision

Adopt human approval for sensitive recommendations and a shared evaluation standard across all three implementations.

### Human approval requirements

- Sensitive recommendations must follow the approval policy.
- Approval decisions must be associated with an authenticated reviewer identity.
- Only authorized users may approve or reject.
- Approval state transitions must be validated.
- Rejected recommendations cannot authorize sensitive actions.
- Approval decisions must be auditable.
- Approval does not imply a real financial transaction.

### Shared evaluation requirements

All three implementations must use the same:

- Evaluation datasets.
- Dataset schemas.
- Evaluation protocol.
- Business rule expectations.
- Core quality metrics.
- Regression criteria.

Evaluation categories include:

1. Ticket classification.
2. Intent and entity extraction.
3. Tool selection.
4. Policy compliance.
5. Response quality.
6. Security and adversarial handling.
7. Workflow correctness.

Implementation-specific performance measurements may be added, but must not replace shared evaluation criteria.

## Initial Business Policy

The following shared policy values apply unless formally revised:

| Policy | Value |
|---|---|
| Return window | 30 calendar days |
| Maximum refund assessment amount | CAD 100 |
| Damaged goods | Image verification required |

These values are part of the synthetic portfolio specification. They do not authorize real refunds.

## Consequences

### Positive

- Human oversight for sensitive decisions.
- Explicit approval lifecycle.
- Consistent evaluation across technologies.
- Easier quality comparison.
- Better regression coverage.

### Negative

- Additional application workflow complexity.
- Shared evaluation assets require maintenance.
- Evaluation results depend on consistent model and prompt configuration.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Approval is incorrectly bypassed | Test approval state transitions and authorization |
| Approval is treated as a financial transaction | Keep approval and transaction execution separate |
| Dataset changes invalidate comparisons | Version datasets and record evaluation versions |
| Different model versions distort comparison | Record provider, model, prompt and configuration versions |
| Evaluation overfits known cases | Maintain adversarial and regression datasets |

## Related Decisions

- ADR-001: Repository Strategy
- ADR-003: Clean Architecture
- ADR-004: Agent Orchestration
