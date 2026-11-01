# ADR-001: Repository Strategy

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owners:** Portfolio maintainers

## Context

The portfolio implements the same AI Customer Support and Ticket Resolution Agent using three different technology stacks:

1. Plain Python.
2. LangChain and LangGraph.
3. Rust.

The portfolio must make it possible to compare implementations without allowing their business requirements, domain definitions, security expectations, and evaluation criteria to drift.

## Decision Drivers

- Independent implementation and development.
- Consistent business behavior.
- Shared requirements and contracts.
- Reusable evaluation datasets.
- Clear Git history.
- Independent documentation and release cycles.
- Portfolio-level comparison.

## Considered Options

### Option A: One repository containing everything

Advantages:
- One repository to manage.
- Shared files are immediately accessible.
- Easier cross-project changes.

Disadvantages:
- Repository structure becomes large.
- Different technology stacks share one development environment.
- Independent implementation releases become harder to manage.
- Comparison boundaries become less explicit.

### Option B: Separate implementation repositories without a shared repository

Advantages:
- Strong implementation independence.
- Simple technology-specific repository structures.

Disadvantages:
- Shared specifications become duplicated.
- Business rules can diverge.
- Evaluation datasets may become inconsistent.

### Option C: One shared repository and three implementation repositories

Advantages:
- Shared specifications have one source of truth.
- Implementations remain independent.
- Common evaluation datasets can be reused.
- Technology-specific engineering remains isolated.
- Easier comparison across implementations.

Disadvantages:
- Shared changes must be synchronized with implementation repositories.
- Contributors must understand the relationship between repositories.
- Cross-repository changes require coordination.

## Decision

Adopt four Git repositories:

| Repository | Responsibility |
|---|---|
| `ai-agent-shared` | Shared specifications, contracts, datasets and standards |
| `ai-agent-py` | Plain Python implementation |
| `ai-agent-lc` | LangChain and LangGraph implementation |
| `ai-agent-rs` | Rust implementation |

`ai-agent-shared` is the authoritative source for shared business requirements, domain definitions, contracts, and evaluation standards.

Implementation repositories must conform to the shared specifications.

## Consequences

### Positive

- Clear separation of responsibilities.
- Independent technology implementations.
- Consistent business requirements.
- Reusable evaluation assets.
- Better architecture comparison.

### Negative

- Cross-repository changes require coordination.
- Shared specification changes may require implementation updates.
- Repository version compatibility must be tracked.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Implementations drift from shared specifications | Maintain contract and evaluation conformance tests |
| Shared documentation becomes outdated | Review shared documentation with every relevant implementation change |
| Incompatible specification changes | Version shared contracts and document breaking changes |

## Related Decisions

- ADR-002: Modular Monolith
- ADR-003: Clean Architecture
- ADR-005: Human Approval and Shared Evaluation
