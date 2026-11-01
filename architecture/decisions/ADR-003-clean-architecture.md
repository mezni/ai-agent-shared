# ADR-003: Clean Architecture

- **Status:** Accepted
- **Date:** 2026-11-01
- **Decision owners:** Portfolio maintainers

## Context

The portfolio uses three different technology stacks to implement the same business capabilities.

The architecture must prevent domain and application logic from becoming dependent on:

- LLM providers.
- Agent frameworks.
- User interface frameworks.
- Storage implementations.
- External service SDKs.

A consistent architecture is necessary to compare the implementations fairly.

## Decision Drivers

- Framework independence.
- Testability.
- Business rule isolation.
- Replaceable technical implementations.
- Consistency across programming languages.
- Clear dependency direction.

## Considered Options

### Option A: Layered Architecture without strict dependency rules

Advantages:
- Familiar structure.
- Easy to introduce.

Disadvantages:
- Business logic can become dependent on infrastructure.
- Dependency direction may be inconsistent.
- Framework details can leak into domain code.

### Option B: Clean Architecture

Advantages:
- Clear separation of responsibilities.
- Inward source-code dependency direction.
- Domain independence.
- Application workflows can be tested without external services.
- Infrastructure can be replaced without rewriting core business logic.

Disadvantages:
- Requires additional interfaces and translation code.
- Can introduce unnecessary abstraction if applied mechanically.

### Option C: Framework-centric architecture

Advantages:
- Faster initial implementation using framework conventions.
- Less initial architectural code.

Disadvantages:
- Business logic becomes framework-dependent.
- Framework migration becomes harder.
- Cross-implementation comparison becomes less consistent.

## Decision

Adopt **Clean Architecture** with four layers:

1. **Entities**
   - Domain models.
   - Business invariants.
   - Core domain policies.

2. **Use Cases**
   - Application workflows.
   - Application-specific business coordination.
   - Application interfaces required by the workflows.

3. **Interface Adapters**
   - Controllers.
   - Presenters.
   - Repository implementations.
   - LLM and tool adapters.
   - Request and response translation.

4. **Frameworks and Drivers**
   - Streamlit.
   - RustView.
   - LangGraph.
   - LLM SDKs.
   - JSON storage.
   - Future database and external infrastructure.

## Dependency Rule

Source-code dependencies point inward.

- Entities do not depend on outer layers.
- Use Cases depend on Entities and application interfaces they define.
- Interface Adapters implement or translate those interfaces.
- Frameworks and Drivers remain replaceable technical details.

The runtime execution flow does not change the source-code dependency rule.

## Implementation Mapping

| Layer | Python | LangChain | Rust |
|---|---|---|---|
| Entities | Python domain models | Python domain models | Rust domain types |
| Use Cases | Application services | Application services | Application services |
| Interface Adapters | Controllers and adapters | Controllers and adapters | Controllers and adapters |
| Frameworks and Drivers | Streamlit, SDKs, JSON | Streamlit, LangGraph, SDKs | RustView, SDKs, JSON |

## Consequences

### Positive

- Shared business rules remain independent of technology.
- LLM and framework replacement is easier.
- Domain tests do not require external services.
- Architectural consistency improves comparisons.

### Negative

- Additional abstractions are required.
- Developers must maintain dependency boundaries.
- Simple operations may require more translation code.

## Constraints

- Do not classify the project as Hexagonal Architecture or Ports and Adapters.
- Do not label application interfaces as input ports or output ports.
- Keep application interfaces in the Use Cases layer.
- Keep concrete implementations in outer layers.
- Do not import framework-specific types into Entities.
- Do not let LLM output bypass domain invariants.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Excessive abstraction | Introduce interfaces only where they protect a real boundary |
| Framework leakage | Add dependency and architecture tests |
| Inconsistent implementations | Use shared specifications and architecture reviews |

## Related Decisions

- ADR-001: Repository Strategy
- ADR-002: Modular Monolith
- ADR-004: Agent Orchestration
