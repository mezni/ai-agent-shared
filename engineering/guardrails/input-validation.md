# Input Validation Standards

## 1. Purpose

Define validation requirements for data entering the AI Support Agent application.

These standards apply to all implementations:

- `ai-agent-py`
- `ai-agent-lc`
- `ai-agent-rs`

Validation must occur before untrusted data is used by application workflows, domain logic, or external integrations.

## 2. Validation Layers

| Layer | Responsibility |
|---|---|
| Interface Adapter | Validate request structure, types, formats and size limits |
| Use Cases | Validate workflow preconditions and operation-specific constraints |
| Entities | Enforce domain invariants |
| Tool Adapter | Validate tool arguments and external responses |
| LLM Adapter | Parse and validate model response format before returning it to the application |

Validation at one layer does not eliminate the need for validation at another layer when the boundary has different responsibilities.

## 3. General Rules

- Reject malformed requests before starting an agent execution.
- Use explicit schemas for external and model-generated data.
- Reject unsupported enum values.
- Apply maximum lengths and request-size limits.
- Normalize values only when normalization is explicitly defined.
- Do not silently replace invalid values with defaults.
- Do not trust client-side validation.
- Do not trust LLM output because it matches a JSON format.
- Return structured errors without exposing internal implementation details.
- Keep validation deterministic and testable.

## 4. Ticket Input Contract

The initial ticket submission request uses this conceptual structure:

```json
{
  "ticket_id": "TICKET-1001",
  "customer_id": "CUST-1001",
  "subject": "Order has not arrived",
  "description": "My order #4821 has not arrived.",
  "created_at": "2026-11-01T12:00:00Z"
}
```

### Field validation

| Field | Required | Validation |
|---|---|---|
| `ticket_id` | Yes | Non-empty string; matches the shared identifier format |
| `customer_id` | Yes | Non-empty string; matches the shared identifier format |
| `subject` | Yes | String; 1–200 characters |
| `description` | Yes | String; 1–10,000 characters |
| `created_at` | Yes | Valid ISO 8601 timestamp with timezone |

Additional rules:

- Reject missing required fields.
- Reject `null` for required fields.
- Reject unexpected fields unless the contract explicitly permits extensions.
- Reject request bodies exceeding the configured size limit.
- Treat subject and description as untrusted text.
- Do not interpret ticket content as application instructions.

## 5. Agent Execution Request

The execution request must reference a valid ticket and contain only supported options.

Validation requirements:

- Ticket identifier must be well-formed.
- Requested workflow must be supported.
- Correlation ID must follow the shared contract.
- Optional configuration must use approved values.
- User identity and roles must come from the authenticated application context, not from model output or untrusted request fields.
- The request must not allow the caller to override business policy.

## 6. Tool Argument Validation

Every tool must define an argument schema.

Example order lookup:

```json
{
  "order_id": "4821"
}
```

Rules:

- Tool name must be in the application allowlist.
- Required arguments must be present.
- Argument types and formats must be valid.
- Unknown arguments must be rejected.
- The tool must verify the requested resource is within the user's permitted data scope.
- Tool arguments must not contain arbitrary code or executable expressions.
- Tool execution must use bounded timeouts and retries.

## 7. Domain-Level Semantic Validation

Syntactically valid data may still violate domain rules.

Examples:

- A refund amount must be non-negative and include a currency.
- A refund assessment must reference an existing order.
- An approval decision must reference an existing pending approval.
- An execution cannot transition from a terminal state to a running state.
- A policy evaluation failure cannot result in `ELIGIBLE`.
- An approval reviewer must have the required role.

These rules belong in domain entities, domain services, or application use cases—not only in request schemas.

## 8. Validation Error Contract

Use the shared error structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request contains invalid fields.",
    "details": [
      {
        "field": "subject",
        "reason": "Field must contain between 1 and 200 characters."
      }
    ],
    "correlation_id": "corr-1001"
  }
}
```

### Error requirements

- `code` must be a stable machine-readable identifier.
- `message` must be safe for the user interface.
- `details` may identify invalid fields without exposing sensitive data.
- `correlation_id` should be included when available.
- Stack traces and secrets must not be returned to users.

Suggested error codes:

| Code | Meaning |
|---|---|
| `VALIDATION_ERROR` | Request or field validation failed |
| `INVALID_IDENTIFIER` | Identifier format is invalid |
| `UNSUPPORTED_VALUE` | Enum or option is not supported |
| `REQUEST_TOO_LARGE` | Request exceeds configured limit |
| `UNAUTHORIZED` | Caller lacks permission |
| `INVALID_STATE` | Requested operation conflicts with current state |
| `INVALID_MODEL_OUTPUT` | LLM response failed validation |
| `TOOL_ARGUMENT_ERROR` | Tool arguments are invalid |

## 9. Validation Testing Requirements

Tests must cover:

- Missing required fields.
- Incorrect field types.
- Empty and oversized strings.
- Invalid identifiers.
- Invalid timestamps.
- Unsupported enum values.
- Unexpected fields.
- Malformed tool arguments.
- Domain invariant violations.
- Invalid state transitions.
- Safe error responses.
- Boundary values and maximum lengths.

## 10. Definition of Done

- [ ] Request schemas are defined.
- [ ] Field types and limits are documented.
- [ ] Tool argument validation is documented.
- [ ] Domain-level semantic validation is distinguished from schema validation.
- [ ] Standard validation error format is defined.
- [ ] Invalid input is rejected before workflow execution.
- [ ] Validation tests cover normal, boundary and invalid cases.
- [ ] Requirements apply consistently across all implementations.
