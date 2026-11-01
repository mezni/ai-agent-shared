# ADR-002: Modular Monolith

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owners:** Portfolio maintainers

## Context

The AI Support Agent contains several business capabilities:

- Ticket classification.
- Intent detection.
- Customer and order retrieval.
- Policy retrieval.
- Refund eligibility assessment.
- Response generation.
- Human approval.
- Audit and observability.

These capabilities need clear boundaries, but the portfolio does not initially require distributed deployment.

## Decision Drivers

- Low initial infrastructure complexity.
- Clear separation of business responsibilities.
- Independent module testing.
- Simple local development.
- Ability to evolve without premature distribution.
- Consistent implementation across three languages.

## Considered Options

### Option A: Monolithic application without module boundaries

Advantages:
- Simple initial setup.
- Minimal architectural overhead.

Disadvantages:
- Business responsibilities become coupled.
- Testing individual capabilities becomes harder.
- Changes may affect unrelated functionality.

### Option B: Modular Monolith

Advantages:
- One deployable application per implementation.
- Clear internal module boundaries.
- Simpler deployment than distributed services.
- Supports independent unit testing.
- Allows future extraction of modules if justified.

Disadvantages:
- Requires discipline around module dependencies.
- Internal boundaries must be maintained through code reviews and tests.

### Option C: Microservices

Advantages:
- Independent deployment and scaling.
- Strong service-level isolation.

Disadvantages:
- Introduces network communication and distributed failure modes.
- Requires service discovery, deployment orchestration and distributed observability.
- Unnecessary for the current portfolio scope.

## Decision

Adopt a **Modular Monolith**.

Each implementation is one independently deployable application containing clearly separated business and technical modules.

Initial modules include:

- Ticket Management.
- Classification.
- Information Retrieval.
- Refund Assessment.
- Response Generation.
- Approval Management.
- Guardrails and Security.
- Evaluation and Observability.

Modules communicate through application-level interfaces and defined contracts.

## Consequences

### Positive

- Reduced infrastructure complexity.
- Easier local development.
- Clear business boundaries.
- Simpler integration testing.
- Independent repository deployments.

### Negative

- Module boundaries require continuous enforcement.
- Scaling individual modules independently is not initially available.
- A poorly designed module can still create coupling inside the application.

## Constraints

- Do not introduce network boundaries between internal modules without a documented requirement.
- Do not share internal implementation details across modules unnecessarily.
- Keep domain rules independent of infrastructure.
- Preserve the possibility of future module extraction.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Monolith becomes tightly coupled | Enforce module boundaries and dependency rules |
| Shared mutable state | Use explicit application contracts |
| Premature microservice extraction | Require an ADR and measurable justification |

## Related Decisions

- ADR-001: Repository Strategy
- ADR-003: Clean Architecture
