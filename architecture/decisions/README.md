# Architecture Decision Records

This directory contains the accepted architectural decisions for the AI Customer Support and Ticket Resolution Agent portfolio.

## Decision Index

| ADR | Decision | Status |
|---|---|---|
| ADR-001 | Repository Strategy | Accepted |
| ADR-002 | Modular Monolith | Accepted |
| ADR-003 | Clean Architecture | Accepted |
| ADR-004 | Agent Orchestration | Accepted |
| ADR-005 | Human Approval and Shared Evaluation | Accepted |

## Decision Principles

- Shared business requirements are maintained in `ai-agent-shared`.
- The three implementation repositories remain independent.
- Each implementation is a Modular Monolith.
- The architecture follows Clean Architecture.
- Source-code dependencies point inward.
- LLMs perform bounded tasks and cannot override deterministic business rules.
- Tool authorization is enforced by application code.
- Sensitive recommendations follow human approval requirements.
- All implementations use shared evaluation standards.

## Changing a Decision

When an accepted decision needs to change:

1. Create a new ADR or revise the existing ADR according to the significance of the change.
2. Document the context and reason for the change.
3. Evaluate alternatives and consequences.
4. Identify affected specifications and implementation repositories.
5. Record the decision status.
6. Update the relevant architecture and engineering documentation.

Do not silently reverse an accepted architectural decision.
