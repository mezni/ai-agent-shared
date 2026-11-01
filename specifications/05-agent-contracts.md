# Shared Agent Contracts

**Project:** AI Customer Support & Ticket Resolution Agent  
**Status:** Initial specification  
**Contract version:** `1.0.0`  
**Applies to:** `ai-agent-py`, `ai-agent-lc`, `ai-agent-rs`

---

## 1. Purpose

This document defines the technology-neutral data contracts shared by all three implementations of the AI Customer Support & Ticket Resolution Agent.

The contracts establish consistent boundaries between:

- The user interface.
- The application and orchestration layer.
- The AI agent.
- Business policy services.
- Customer, order, and policy lookup tools.
- Human approval workflows.
- Evaluation and observability components.

Each implementation may use different programming languages, frameworks, and internal data structures. However, externally observable contract behavior must remain consistent.

## 2. Contract design principles

1. **Technology independence:** Contracts must not depend on Python, LangChain, LangGraph, Rust, or a UI framework.
2. **Explicit versioning:** Every externally exchanged contract must identify its version.
3. **Structured data:** Use explicit field names, types, and enumerated values.
4. **Deterministic decisions:** Business policy outcomes must be produced by deterministic application services.
5. **Human authorization:** Sensitive recommendations require an authorized human decision before any protected action.
6. **Traceability:** Requests, tool calls, decisions, and audit events must be correlated through identifiers.
7. **Least privilege:** Tool authorization is enforced by the application, not by model-generated arguments.
8. **No secrets in contracts:** API keys, passwords, access tokens, and other credentials must never be included in agent-visible payloads.
9. **Safe failure:** Errors must be structured and must not be interpreted as successful results.
10. **Cross-implementation consistency:** Equivalent inputs must produce equivalent business outcomes across all three repositories.

## 3. Common conventions

### 3.1 Field naming

Use `snake_case` for JSON property names.

### 3.2 Identifiers

Identifiers are strings. Examples:

- `ticket_id`
- `customer_id`
- `order_id`
- `execution_id`
- `decision_id`
- `tool_execution_id`
- `approval_id`
- `audit_event_id`

Identifiers must be unique within their defined resource scope.

### 3.3 Timestamps

Use ISO 8601 timestamps in UTC.

Example:

`2026-10-31T14:30:00Z`

### 3.4 Confidence

Confidence scores are numeric values between `0.0` and `1.0`, inclusive.

They express model confidence, not business-policy certainty or authorization.

### 3.5 Monetary values

Represent monetary amounts as decimal strings to avoid floating-point precision problems.

Example:

```json
{
  "amount": "49.99",
  "currency": "CAD"
}
```

The currency must be an ISO 4217 currency code. Implementations must not use binary floating-point arithmetic for monetary calculations.

### 3.6 Optional and nullable fields

- Required fields must always be present.
- Optional fields may be omitted when unavailable.
- A field may be `null` only when its contract explicitly permits null.
- Missing data must not be silently replaced with fabricated values.

## 4. Ticket Input Contract

**Purpose:** Represent a support ticket submitted to the agent.

```json
{
  "ticket_id": "TICKET-1001",
  "customer_id": "CUSTOMER-501",
  "subject": "My order has not arrived",
  "description": "My order ORD-2001 was expected yesterday.",
  "channel": "web",
  "created_at": "2026-10-31T14:30:00Z"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `ticket_id` | string | Yes | Unique ticket identifier |
| `customer_id` | string | Yes | Customer reference |
| `subject` | string | Yes | Ticket subject |
| `description` | string | Yes | Ticket content |
| `channel` | string | Yes | Submission channel |
| `created_at` | timestamp | Yes | Ticket creation time |

Supported initial channels:

- `web`
- `email`
- `chat`
- `phone`

The initial implementation uses synthetic ticket data.

## 5. Agent Execution Request

**Purpose:** Start an agent execution for a ticket.

```json
{
  "contract_version": "1.0.0",
  "request_id": "REQ-1001",
  "ticket": {
    "ticket_id": "TICKET-1001",
    "customer_id": "CUSTOMER-501",
    "subject": "My order has not arrived",
    "description": "My order ORD-2001 was expected yesterday.",
    "channel": "web",
    "created_at": "2026-10-31T14:30:00Z"
  }
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `contract_version` | string | Yes | Contract version |
| `request_id` | string | Yes | Unique request identifier |
| `ticket` | object | Yes | Ticket Input Contract |

The application creates the execution identity and establishes the authenticated user context. The LLM must not be allowed to choose or impersonate the executing user.

## 6. Agent Decision Contract

**Purpose:** Represent the AI agent's proposed interpretation of a ticket.

```json
{
  "decision_id": "DEC-1001",
  "execution_id": "EXEC-1001",
  "intent": "DELIVERY_ISSUE",
  "confidence": 0.94,
  "entities": {
    "order_id": "ORD-2001"
  },
  "reasoning_summary": "The customer reports that the order has not arrived.",
  "proposed_actions": [
    "LOOKUP_ORDER",
    "CHECK_DELIVERY_STATUS"
  ],
  "requires_human_review": false
}
```

Supported initial intents:

- `ORDER_INQUIRY`
- `REFUND_REQUEST`
- `DELIVERY_ISSUE`
- `PRODUCT_QUESTION`
- `COMPLAINT`
- `UNKNOWN`

| Field | Type | Required | Description |
|---|---|---|---|
| `decision_id` | string | Yes | Decision identifier |
| `execution_id` | string | Yes | Associated execution |
| `intent` | string | Yes | Proposed ticket intent |
| `confidence` | number | Yes | Confidence between 0 and 1 |
| `entities` | object | Yes | Extracted structured entities |
| `reasoning_summary` | string | Yes | Short explanation of the proposal |
| `proposed_actions` | array | Yes | Proposed application actions |
| `requires_human_review` | boolean | Yes | Whether review is recommended |

**Important constraints:**

- This is an AI proposal, not an authoritative business decision.
- Extracted identifiers must be validated before use.
- Proposed actions must be checked against application capabilities and authorization rules.
- The application must not treat a high confidence score as permission to execute an action.
- Do not expose private internal model reasoning. `reasoning_summary` is a concise, user-safe explanation.

## 7. Tool Invocation Request Contract

**Purpose:** Request execution of an application-controlled tool.

```json
{
  "contract_version": "1.0.0",
  "request_id": "TOOL-REQ-1001",
  "tool_execution_id": "TOOL-EXEC-1001",
  "execution_id": "EXEC-1001",
  "tool_name": "order_lookup",
  "arguments": {
    "order_id": "ORD-2001"
  }
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `contract_version` | string | Yes | Contract version |
| `request_id` | string | Yes | Unique invocation request |
| `tool_execution_id` | string | Yes | Tool execution identifier |
| `execution_id` | string | Yes | Parent agent execution |
| `tool_name` | string | Yes | Registered tool name |
| `arguments` | object | Yes | Validated tool arguments |

Initial registered tools:

- `customer_lookup`
- `order_lookup`
- `policy_lookup`

**Security requirements:**

1. The application maintains the trusted identity and authorization context.
2. The model cannot grant itself permissions.
3. The tool registry defines permitted arguments and schemas.
4. The application validates arguments before execution.
5. Tool access must be denied when authorization fails.
6. Secrets and credentials must never appear in the tool arguments.
7. Unknown tool names must be rejected.

The authenticated principal and authorization context are application-side execution metadata. They are deliberately not trusted fields in the model-generated request.

## 8. Tool Result Contract

**Purpose:** Return a structured result from a tool invocation.

Successful example:

```json
{
  "tool_execution_id": "TOOL-EXEC-1001",
  "execution_id": "EXEC-1001",
  "tool_name": "order_lookup",
  "status": "SUCCEEDED",
  "data": {
    "order_id": "ORD-2001",
    "customer_id": "CUSTOMER-501",
    "status": "SHIPPED",
    "delivery_date": null
  },
  "error": null,
  "duration_ms": 42
}
```

Failed example:

```json
{
  "tool_execution_id": "TOOL-EXEC-1002",
  "execution_id": "EXEC-1001",
  "tool_name": "order_lookup",
  "status": "FAILED",
  "data": null,
  "error": {
    "code": "NOT_FOUND",
    "message": "The requested order was not found.",
    "retryable": false
  },
  "duration_ms": 18
}
```

Supported tool execution statuses:

- `PENDING`
- `RUNNING`
- `SUCCEEDED`
- `FAILED`
- `TIMED_OUT`
- `DENIED`

Supported error codes:

- `NOT_FOUND`
- `VALIDATION_ERROR`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `TIMEOUT`
- `UNAVAILABLE`
- `INTERNAL_ERROR`

Rules:

- `SUCCEEDED` requires a valid result.
- A failed or denied tool call must never be treated as a successful lookup.
- Error messages must not expose credentials, internal stack traces, or sensitive implementation details.
- A retry must retain traceability to the original execution.

## 9. Refund Assessment Contract

**Purpose:** Return the authoritative result of deterministic refund-policy evaluation.

```json
{
  "assessment_id": "ASSESS-1001",
  "execution_id": "EXEC-1001",
  "order_id": "ORD-2001",
  "eligibility": "INELIGIBLE",
  "reason_codes": [
    "RETURN_WINDOW_EXPIRED"
  ],
  "policy_version": "refund-policy-1.0",
  "assessed_at": "2026-10-31T14:32:00Z",
  "requires_human_review": false
}
```

Supported eligibility values:

- `ELIGIBLE`
- `INELIGIBLE`
- `PENDING_REVIEW`

Initial policy decisions:

- Return window: 30 calendar days.
- Refund cap: CAD 100 per transaction.
- Damaged goods: require image verification.
- Eligibility is determined by application policy services.
- The LLM cannot modify or override the result.

| Field | Type | Required | Description |
|---|---|---|---|
| `assessment_id` | string | Yes | Assessment identifier |
| `execution_id` | string | Yes | Associated execution |
| `order_id` | string | Yes | Assessed order |
| `eligibility` | string | Yes | Deterministic outcome |
| `reason_codes` | array | Yes | Machine-readable policy reasons |
| `policy_version` | string | Yes | Policy version used |
| `assessed_at` | timestamp | Yes | Assessment timestamp |
| `requires_human_review` | boolean | Yes | Whether additional review is required |

An `ELIGIBLE` result does not itself authorize a financial transaction. The initial portfolio project does not execute real refunds.

## 10. Approval Request Contract

**Purpose:** Request human review of a recommendation.

```json
{
  "approval_id": "APP-1001",
  "execution_id": "EXEC-1001",
  "decision_id": "DEC-1001",
  "assessment_id": "ASSESS-1001",
  "requested_action": "REVIEW_REFUND_RECOMMENDATION",
  "status": "PENDING",
  "requested_at": "2026-10-31T14:33:00Z"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `approval_id` | string | Yes | Approval request identifier |
| `execution_id` | string | Yes | Associated execution |
| `decision_id` | string | Yes | Associated agent proposal |
| `assessment_id` | string | No | Related refund assessment |
| `requested_action` | string | Yes | Action requiring review |
| `status` | string | Yes | Approval status |
| `requested_at` | timestamp | Yes | Request timestamp |

Supported approval statuses:

- `PENDING`
- `APPROVED`
- `REJECTED`
- `CANCELLED`

The approval request must identify the exact recommendation under review. It must not be possible to approve an unrelated or subsequently modified recommendation by reusing an old approval reference.

## 11. Approval Decision Contract

**Purpose:** Record an authorized human's decision.

```json
{
  "approval_id": "APP-1001",
  "decision": "APPROVED",
  "reviewer_id": "USER-200",
  "reviewed_at": "2026-10-31T14:35:00Z",
  "comment": "Reviewed the recommendation and supporting order information.",
  "idempotency_key": "APP-1001-REVIEW-1"
}
```

Supported decisions:

- `APPROVED`
- `REJECTED`

Requirements:

1. Reviewer identity must come from authenticated application context.
2. The application must verify the reviewer's role and permissions.
3. A reviewer cannot approve their own request if a future policy prohibits self-approval.
4. A completed decision cannot be silently overwritten.
5. Duplicate submissions must be handled idempotently.
6. Rejection must not authorize the requested action.
7. Every decision must generate an auditable event.

The `reviewer_id` shown in the example is the identity recorded by the application. It must not be trusted merely because a client or model supplied it.

## 12. Suggested Response Contract

**Purpose:** Prepare a proposed customer-facing message.

```json
{
  "response_id": "RESP-1001",
  "execution_id": "EXEC-1001",
  "ticket_id": "TICKET-1001",
  "language": "en",
  "content": "Your order has shipped. We are checking its delivery status and will provide an update.",
  "requires_human_review": false,
  "generated_at": "2026-10-31T14:36:00Z"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `response_id` | string | Yes | Response identifier |
| `execution_id` | string | Yes | Associated execution |
| `ticket_id` | string | Yes | Associated ticket |
| `language` | string | Yes | Language code |
| `content` | string | Yes | Suggested response |
| `requires_human_review` | boolean | Yes | Whether review is required |
| `generated_at` | timestamp | Yes | Generation timestamp |

The response must:

- Use verified information only.
- Avoid inventing order, customer, or policy facts.
- Avoid promising an action that has not been authorized or completed.
- Be checked against output guardrails.
- Remain a suggestion until the application authorizes its delivery.

## 13. Agent Execution Result Contract

**Purpose:** Return the outcome of an agent execution.

```json
{
  "contract_version": "1.0.0",
  "execution_id": "EXEC-1001",
  "request_id": "REQ-1001",
  "ticket_id": "TICKET-1001",
  "status": "WAITING_FOR_APPROVAL",
  "decision": {
    "decision_id": "DEC-1001",
    "intent": "REFUND_REQUEST",
    "confidence": 0.96
  },
  "refund_assessment": {
    "assessment_id": "ASSESS-1001",
    "eligibility": "ELIGIBLE",
    "reason_codes": [],
    "policy_version": "refund-policy-1.0"
  },
  "approval_request": {
    "approval_id": "APP-1001",
    "status": "PENDING"
  },
  "suggested_response": null,
  "errors": [],
  "started_at": "2026-10-31T14:30:00Z",
  "completed_at": null
}
```

Supported execution statuses:

- `PENDING`
- `RUNNING`
- `WAITING_FOR_APPROVAL`
- `COMPLETED`
- `FAILED`
- `ESCALATED`

Rules:

- `WAITING_FOR_APPROVAL` requires a pending approval request.
- `COMPLETED` means the defined workflow completed; it does not imply that a real refund was executed.
- `FAILED` must include an appropriate error.
- `ESCALATED` must identify the escalation outcome in the associated execution or audit history.
- Optional result objects may be omitted or set to null according to the formal schema adopted later.

## 14. Audit Event Contract

**Purpose:** Record important events throughout an execution.

```json
{
  "audit_event_id": "AUDIT-1001",
  "execution_id": "EXEC-1001",
  "ticket_id": "TICKET-1001",
  "event_type": "REFUND_ASSESSED",
  "occurred_at": "2026-10-31T14:32:00Z",
  "actor_type": "POLICY_ENGINE",
  "actor_id": "refund-policy-service",
  "resource_id": "ASSESS-1001",
  "outcome": "INELIGIBLE",
  "metadata": {
    "policy_version": "refund-policy-1.0",
    "reason_codes": [
      "RETURN_WINDOW_EXPIRED"
    ]
  }
}
```

Initial event types:

- `TICKET_SUBMITTED`
- `TICKET_CLASSIFIED`
- `ORDER_RETRIEVED`
- `POLICY_RETRIEVED`
- `REFUND_ASSESSED`
- `APPROVAL_REQUESTED`
- `APPROVAL_GRANTED`
- `APPROVAL_REJECTED`
- `TICKET_ESCALATED`
- `AGENT_EXECUTION_COMPLETED`

Actor types:

- `USER`
- `AI_AGENT`
- `APPLICATION`
- `POLICY_ENGINE`
- `TOOL`
- `SYSTEM`

Audit records must be append-only from the application's perspective. Sensitive information, credentials, and unnecessary customer data must not be copied into event metadata.

## 15. Standard Error Contract

**Purpose:** Provide a consistent error structure across implementations.

```json
{
  "code": "VALIDATION_ERROR",
  "message": "The supplied order identifier is invalid.",
  "retryable": false,
  "correlation_id": "CORR-1001",
  "details": {}
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `code` | string | Yes | Stable error code |
| `message` | string | Yes | Safe, understandable description |
| `retryable` | boolean | Yes | Whether retry may be appropriate |
| `correlation_id` | string | Yes | Request correlation identifier |
| `details` | object | No | Safe structured diagnostic context |

Implementations must distinguish validation, authorization, missing-resource, timeout, availability, and internal errors.

Do not expose stack traces or secrets through public error responses.

## 16. Correlation and traceability

The application must establish an `execution_id` for every agent execution.

The following identifiers should be propagated where applicable:

- `request_id`
- `correlation_id`
- `execution_id`
- `ticket_id`
- `decision_id`
- `tool_execution_id`
- `assessment_id`
- `approval_id`
- `audit_event_id`

This allows an operator to reconstruct the execution lifecycle and correlate logs, tool results, decisions, evaluations, and approval records.

## 17. Contract versioning

Use semantic versioning:

`MAJOR.MINOR.PATCH`

Examples:

- `1.0.0`: Initial shared contract.
- `1.1.0`: Backward-compatible optional field addition.
- `1.0.1`: Documentation clarification or non-breaking correction.
- `2.0.0`: Breaking field, type, or behavior change.

Compatibility rules:

1. Do not silently change the meaning of an existing field.
2. Do not change an enum's meaning without a versioned contract decision.
3. Additive optional fields may be backward-compatible.
4. Removing or renaming required fields requires a major version.
5. All three implementations must pass shared contract tests before adopting a new version.
6. Document migrations and compatibility expectations.

## 18. Cross-implementation requirements

All implementations must satisfy the following:

| ID | Requirement |
|---|---|
| CONTRACT-001 | Use the same field names and data types |
| CONTRACT-002 | Use the same enum values |
| CONTRACT-003 | Validate required fields |
| CONTRACT-004 | Reject invalid confidence scores |
| CONTRACT-005 | Preserve monetary precision |
| CONTRACT-006 | Propagate execution and correlation identifiers |
| CONTRACT-007 | Separate AI proposals from policy decisions |
| CONTRACT-008 | Enforce tool authorization outside the LLM |
| CONTRACT-009 | Require authorized human decisions for protected workflows |
| CONTRACT-010 | Produce consistent structured errors |
| CONTRACT-011 | Record significant workflow events |
| CONTRACT-012 | Maintain contract version compatibility |

## 19. Contract ownership

| Contract | Responsible component |
|---|---|
| Ticket Input | Application boundary |
| Agent Execution Request | Application boundary |
| Agent Decision | Agent / orchestration layer |
| Tool Invocation Request | Application tool adapter |
| Tool Result | Tool adapter |
| Refund Assessment | Domain policy service |
| Approval Request | Approval application service |
| Approval Decision | Authorized human / approval service |
| Suggested Response | Agent / response service |
| Execution Result | Orchestration layer |
| Audit Event | Observability / audit service |

## 20. Formal schema implementation

This document defines the initial shared contract specification using illustrative JSON examples.

During the shared test foundation stage, the contracts will be translated into formal JSON Schema files. Those schemas will become the machine-readable source for:

- Contract validation.
- Shared fixture validation.
- Cross-language compatibility tests.
- Integration tests.
- Evaluation input and output validation.

The three implementation repositories must not independently redefine the business meaning of these contracts.

## 21. Definition of Done

- [ ] All initial agent and application boundaries are documented.
- [ ] Ticket and execution request contracts are defined.
- [ ] Agent decision contract is defined.
- [ ] Tool invocation and result contracts are defined.
- [ ] Refund assessment contract is defined.
- [ ] Approval request and decision contracts are defined.
- [ ] Suggested response and execution result contracts are defined.
- [ ] Audit and error contracts are defined.
- [ ] Versioning and compatibility rules are documented.
- [ ] Security and authorization boundaries are explicit.
- [ ] Contract decisions are consistent with the shared domain model.
- [ ] The specification is committed to `ai-agent-shared`.

---

**Next step:** Define the system architecture and show how these contracts connect the major components.
