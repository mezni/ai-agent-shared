# Observability Strategy

## 1. Purpose

This document defines the shared observability standards for the AI Customer Support & Ticket Resolution Agent.

The goal is to make agent behavior measurable, diagnosable, and auditable across all three implementations:

- Plain Python with a custom orchestrator.
- LangChain and LangGraph.
- Rust with RustView.

Observability must provide visibility into application execution without unnecessarily exposing customer information, credentials, or other sensitive data.

## 2. Scope

This standard covers:

- Structured application logging.
- Execution and workflow tracing.
- Operational and business metrics.
- Correlation identifiers.
- Agent execution lifecycle tracking.
- LLM operation visibility.
- Tool execution visibility.
- Policy and approval event visibility.
- Error classification.
- Evaluation and regression observability.
- Alerting and operational diagnostics.

This is an application-level standard. It does not prescribe a specific production monitoring vendor.

## 3. Observability Principles

The system follows these principles:

1. Structured: logs and events use consistent machine-readable fields.
2. Correlated: related operations share execution and trace identifiers.
3. Measurable: important system behavior is represented by metrics.
4. Traceable: significant decisions can be followed through the workflow.
5. Secure: telemetry must not expose credentials or unnecessary personal information.
6. Actionable: failures must contain enough context to support diagnosis.
7. Consistent: all implementations follow the same semantic conventions.
8. Provider-neutral: instrumentation should not depend unnecessarily on one observability vendor.

Observability must support both technical operations and business workflow analysis.

## 4. Three Observability Signals

### 4.1 Logs

Logs describe individual application events.

Examples:

- Ticket received.
- Classification completed.
- Order lookup started.
- Order lookup failed.
- Refund assessment completed.
- Human approval requested.
- Response validation rejected an output.

Logs answer: **What happened?**

### 4.2 Traces

Traces represent the execution path of an operation across application components.

A trace can contain multiple spans representing:

- Ticket intake.
- Classification.
- Entity extraction.
- Customer or order lookup.
- Policy assessment.
- LLM invocation.
- Tool execution.
- Output validation.
- Approval workflow.
- Response generation.

Traces answer: **Where did the operation spend time, and where did it fail?**

### 4.3 Metrics

Metrics are numerical measurements aggregated over time.

Examples:

- Agent execution count.
- Successful execution rate.
- Tool failure rate.
- LLM latency.
- Policy evaluation failures.
- Approval waiting time.
- Evaluation accuracy.

Metrics answer: **How is the system behaving over time?**

These signals complement each other. Metrics identify patterns, traces locate the execution path, and logs explain individual events.

## 5. Correlation Identifiers

Every agent execution must have a unique `execution_id`.

The application must also support:

| Identifier | Purpose |
|---|---|
| `request_id` | Identifies an incoming application request |
| `execution_id` | Identifies one complete agent execution |
| `ticket_id` | Identifies the ticket being processed |
| `trace_id` | Identifies a distributed or application trace |
| `span_id` | Identifies an individual operation within a trace |
| `tool_execution_id` | Identifies a specific tool execution |
| `approval_id` | Identifies a human approval record |

Identifiers must be propagated across relevant components.

### Requirements

- Generate an execution identifier at the beginning of an agent execution.
- Preserve it throughout the workflow.
- Associate logs and spans with the execution.
- Associate tool execution records with the execution.
- Associate approval events with the relevant execution.
- Do not use customer email addresses, phone numbers, or other personal information as correlation identifiers.

The `execution_id` is an application-level identifier. The `trace_id` follows the tracing instrumentation convention. They may be associated but must not be assumed to be identical.

## 6. Agent Execution Lifecycle

The system must make the following lifecycle observable:

1. Request received.
2. Input validation completed.
3. Agent execution created.
4. Intent classification completed.
5. Required context retrieved.
6. Policy assessment completed.
7. Tool operations executed.
8. LLM response generated.
9. Output validation completed.
10. Approval requested, if required.
11. Approval decision recorded.
12. Final response prepared.
13. Execution completed or failed.

Not every execution uses every stage.

The application must record the stages actually executed rather than generating misleading events for skipped stages.

### Execution status

The application should use consistent execution statuses:

- `STARTED`
- `RUNNING`
- `WAITING_FOR_APPROVAL`
- `COMPLETED`
- `FAILED`
- `CANCELLED`

The domain's authoritative execution state remains separate from observability telemetry.

## 7. Structured Logging Standard

Application logs must be structured and machine-readable.

JSON is the recommended interchange format.

### Required fields

| Field | Description |
|---|---|
| `timestamp` | Event timestamp in UTC |
| `level` | Log severity |
| `service` | Application or service identifier |
| `environment` | Execution environment |
| `event_name` | Stable event name |
| `request_id` | Request correlation identifier, when available |
| `execution_id` | Agent execution identifier, when available |
| `trace_id` | Trace identifier, when available |
| `component` | Component producing the event |
| `status` | Operation outcome, where applicable |

Optional fields may include:

- `ticket_id`, if appropriately classified and authorized.
- `tool_name`.
- `duration_ms`.
- `error_code`.
- `policy_version`.
- `approval_id`.
- `model_provider`.
- `model_name`.

Optional fields must follow the data protection standard.

### Example

```json
{
  "timestamp": "2026-10-31T14:30:00Z",
  "level": "INFO",
  "service": "ai-agent-py",
  "environment": "development",
  "event_name": "refund_assessment.completed",
  "request_id": "req-synthetic-001",
  "execution_id": "exec-synthetic-001",
  "component": "refund_policy_service",
  "status": "COMPLETED",
  "policy_version": "v1"
}
```

The example uses synthetic identifiers.

### Log severity

| Level | Usage |
|---|---|
| DEBUG | Detailed development diagnostics |
| INFO | Normal application lifecycle events |
| WARNING | Unexpected but recoverable conditions |
| ERROR | Operation failed |
| CRITICAL | Severe failure requiring immediate attention |

Production logging must avoid excessive DEBUG output.

## 8. Distributed and Workflow Tracing

The system should use OpenTelemetry-compatible instrumentation where practical.

Instrumentation must remain behind an application-level observability abstraction where useful.

### Recommended trace structure

```text
agent.execution
├── request.validation
├── intent.classification
├── entity.extraction
├── context.retrieval
│   ├── customer.lookup
│   └── order.lookup
├── refund.assessment
├── tool.execution
├── llm.generation
├── output.validation
├── approval.workflow
└── response.preparation
```

This represents a logical workflow. Actual span creation depends on which operations execute.

### Span requirements

A span should capture:

- Operation name.
- Start and end timestamps.
- Outcome.
- Relevant correlation identifiers.
- Component name.
- Error classification, if applicable.

Where appropriate, capture:

- Model provider and model name.
- Tool name.
- Policy version.
- Retry count.
- Token usage, if supplied reliably by the provider.
- Timeout information.

Do not record full prompts, full responses, credentials, or unnecessary customer content as span attributes.

### Trace propagation

Where the application calls another service, propagate trace context using supported instrumentation conventions.

For the initial local implementation, traces may remain within the process. Cross-service propagation becomes relevant when external service integrations are introduced.

## 9. Metrics Strategy

Metrics must measure technical reliability, workflow behavior, and agent quality.

### 9.1 Operational metrics

| Metric | Description |
|---|---|
| `agent_executions_total` | Total agent executions |
| `agent_execution_duration_seconds` | Total execution duration |
| `agent_execution_failures_total` | Failed agent executions |
| `tool_executions_total` | Total tool executions |
| `tool_execution_failures_total` | Failed tool executions |
| `llm_requests_total` | Total LLM requests |
| `llm_request_duration_seconds` | LLM request duration |
| `llm_request_failures_total` | Failed LLM requests |
| `validation_failures_total` | Input or output validation failures |

### 9.2 Workflow metrics

| Metric | Description |
|---|---|
| `refund_assessments_total` | Refund assessments performed |
| `refund_assessment_failures_total` | Failed refund assessments |
| `approval_requests_total` | Approval requests created |
| `approval_decisions_total` | Approval decisions recorded |
| `approval_wait_duration_seconds` | Time spent waiting for approval |
| `escalations_total` | Tickets escalated for human handling |

Metrics must not imply that an approval request is an approved action.

### 9.3 Evaluation metrics

Evaluation results should be associated with:

- Dataset version.
- Evaluation run identifier.
- Implementation name.
- Model and configuration version, where available.
- Evaluation timestamp.
- Metric results.

Evaluation metrics include:

- Classification accuracy.
- Macro F1.
- Entity extraction accuracy.
- Tool selection accuracy.
- Policy decision accuracy.
- Evidence support rate.
- Response quality score.
- Cross-implementation policy parity.

The authoritative thresholds remain in `engineering/evaluation/metrics.md`.

## 10. Metric Design and Cardinality

Metrics must use bounded labels.

Appropriate labels include:

- `implementation`
- `environment`
- `operation`
- `status`
- `tool_name`
- `error_code`
- `model_provider`

Avoid high-cardinality or sensitive labels such as:

- Customer email.
- Customer name.
- Ticket text.
- Full order identifier.
- Prompt content.
- Execution identifier.
- Request identifier.

Correlation identifiers belong in logs and traces, not as unbounded metric labels.

## 11. Error Classification

Failures must be classified consistently.

Recommended error categories:

| Error code | Meaning |
|---|---|
| `INPUT_VALIDATION_FAILED` | Request failed input validation |
| `AUTHORIZATION_DENIED` | Access was not authorized |
| `RESOURCE_NOT_FOUND` | Requested resource was not found |
| `TOOL_EXECUTION_FAILED` | Tool operation failed |
| `TOOL_TIMEOUT` | Tool exceeded its allowed execution time |
| `LLM_REQUEST_FAILED` | LLM request failed |
| `LLM_TIMEOUT` | LLM request exceeded its timeout |
| `OUTPUT_VALIDATION_FAILED` | Generated output failed validation |
| `POLICY_EVALUATION_FAILED` | Deterministic policy assessment failed |
| `APPROVAL_REQUIRED` | Workflow requires human approval |
| `APPROVAL_REJECTED` | Approval was rejected |
| `INTERNAL_ERROR` | Unexpected application failure |

An error code must not replace the underlying exception or diagnostic information.

Sensitive exception content must be redacted before logging.

## 12. LLM Observability

LLM operations require additional visibility because latency, provider errors, and output quality affect agent behavior.

Record, where available:

- Provider.
- Model identifier.
- Operation type.
- Request duration.
- Token usage.
- Retry count.
- Timeout status.
- Structured output validation status.
- Failure category.

Do not log full prompts or responses by default.

LLM observability must not treat model-generated claims as authoritative policy decisions.

A successful LLM request does not imply a successful agent execution.

## 13. Tool Observability

Every tool execution must be observable.

Capture:

- Tool execution identifier.
- Tool name.
- Agent execution identifier.
- Start and completion timestamps.
- Execution duration.
- Authorization outcome.
- Validation outcome.
- Execution status.
- Error category, when applicable.

Tool execution must distinguish:

- Requested.
- Authorized.
- Executed.
- Completed.
- Failed.
- Denied.

A denied tool call must not be recorded as a successful execution.

Tool arguments and results must be redacted or minimized according to the data protection standard.

## 14. Policy and Approval Observability

Policy and approval events are important business control points.

The application must make the following events traceable:

- Policy evaluation started.
- Policy evaluation completed.
- Policy evaluation failed.
- Refund assessment produced.
- Approval required.
- Approval requested.
- Approval approved.
- Approval rejected.
- Approval expired or cancelled, if supported.

Record the applicable policy version.

Record the approval actor and outcome through the authoritative approval and audit mechanisms.

Observability must not become the authoritative source of approval state. Domain records and audit events remain authoritative.

## 15. Audit Events Versus Operational Logs

Operational logs and audit events serve different purposes.

| Operational logs | Audit events |
|---|---|
| Support debugging | Record significant business and security actions |
| May have shorter retention | Require separately defined retention |
| Capture technical execution | Capture accountable actor and decision |
| May be sampled in some environments | Must not be silently sampled or discarded |
| Optimize operational diagnosis | Preserve decision history and accountability |

Examples of audit-worthy events:

- Authorization denied for a protected resource.
- Refund assessment finalized.
- Approval requested.
- Approval approved or rejected.
- Sensitive tool execution authorized or denied.
- Policy version used in a significant decision.

Audit event integrity and access controls must be defined separately.

## 16. Sampling and Retention

Tracing and telemetry volume may grow significantly.

Requirements:

- Preserve error traces according to the operational policy.
- Apply sampling carefully.
- Never use sampling to bypass required audit records.
- Avoid collecting sensitive payloads.
- Define retention by telemetry category.
- Restrict access to telemetry.
- Document any dropped or unavailable telemetry where practical.

Initial local development may use unsampled traces for simplicity.

Production sampling and retention settings must be selected using measured workload and operational requirements.

## 17. Dashboards and Operational Views

Future operational dashboards should include:

### Agent health

- Execution volume.
- Successful execution rate.
- Failure rate.
- Execution latency.

### LLM health

- Request volume.
- Latency distribution.
- Timeout rate.
- Provider failure rate.
- Token usage, when available.

### Tool health

- Execution volume by tool.
- Failure rate by tool.
- Authorization denials.
- Timeout frequency.

### Business workflow

- Refund assessment outcomes.
- Approval requests.
- Approval decisions.
- Escalation volume.

### Quality

- Evaluation results.
- Regression failures.
- Policy decision parity.
- Response quality.

Dashboards must not expose sensitive customer data to unauthorized viewers.

## 18. Alerting Strategy

Alert definitions should be based on measured behavior.

Potential alerts include:

- Sustained agent execution failure rate.
- Repeated LLM provider failures.
- Tool timeout spikes.
- Unexpected authorization failures.
- Policy evaluation failures.
- Approval workflow processing failures.
- Missing or degraded telemetry.

Security-critical events may require immediate notification through an approved operational mechanism.

Numeric alert thresholds remain open until representative baselines are measured.

## 19. Clean Architecture Responsibilities

| Layer | Observability responsibility |
|---|---|
| Entities | Preserve valid domain state and decision invariants |
| Use Cases | Emit meaningful application-level execution events through defined abstractions |
| Interface Adapters | Translate application events into telemetry formats |
| Frameworks and Drivers | Provide logging, tracing, metrics exporters, and monitoring infrastructure |

The Dependency Rule remains unchanged: source-code dependencies point inward.

Observability must not become a reason for domain entities to depend directly on a monitoring vendor.

## 20. Cross-Implementation Requirements

### Plain Python

- Use structured logging.
- Generate and propagate execution identifiers.
- Instrument custom orchestrator stages.
- Measure tool and LLM operation durations.
- Keep telemetry configuration outside domain logic.

### LangChain and LangGraph

- Associate graph execution with the application execution identifier.
- Instrument graph nodes and relevant transitions.
- Record tool execution outcomes.
- Record interrupt and resume events for human approval.
- Avoid persisting unnecessary sensitive data in traces or checkpoints.
- Keep framework-specific telemetry behind the shared observability contract where practical.

### Rust

- Use structured tracing.
- Propagate correlation identifiers.
- Instrument orchestrator stages and tool execution.
- Record workflow outcomes.
- Keep telemetry vendor dependencies out of domain entities.

All implementations must expose equivalent business-level events even if their instrumentation libraries differ.

## 21. Observability Testing

| ID | Test | Expected result |
|---|---|---|
| OBS-001 | Start an agent execution | Execution identifier created |
| OBS-002 | Run a multi-stage workflow | Related events share correlation identifiers |
| OBS-003 | Trigger a tool failure | Failure event and error category recorded |
| OBS-004 | Trigger an LLM timeout | Timeout observable |
| OBS-005 | Trigger output validation failure | Validation failure recorded |
| OBS-006 | Request human approval | Approval event associated with execution |
| OBS-007 | Reject approval | Rejection is distinguishable from approval |
| OBS-008 | Inspect metric labels | No sensitive or unbounded identifiers |
| OBS-009 | Inspect logs | No secrets or unnecessary personal information |
| OBS-010 | Inspect traces | No full prompts or sensitive payloads by default |
| OBS-011 | Trigger policy evaluation failure | Failure is visible and not represented as eligible |
| OBS-012 | Compare implementations | Equivalent business events are observable |

## 22. Definition of Done

- [ ] Logging, tracing, and metrics are defined.
- [ ] Correlation identifiers are standardized.
- [ ] Agent lifecycle events are documented.
- [ ] Structured logging fields are specified.
- [ ] Trace structure and span requirements are documented.
- [ ] Operational and workflow metrics are defined.
- [ ] Metric cardinality restrictions are documented.
- [ ] Error categories are standardized.
- [ ] LLM and tool observability requirements are defined.
- [ ] Policy and approval events are covered.
- [ ] Audit events are distinguished from operational logs.
- [ ] Sampling and retention requirements are documented.
- [ ] Dashboard and alerting requirements are defined.
- [ ] Clean Architecture responsibilities are mapped.
- [ ] Python, LangChain/LangGraph, and Rust requirements are aligned.
- [ ] Observability tests are specified.

## 23. Traceability

Related standards:

- `engineering/security/threat-model.md`
- `engineering/security/authentication-authorization.md`
- `engineering/security/data-protection.md`
- `engineering/evaluation/strategy.md`
- `engineering/evaluation/metrics.md`
- `engineering/testing/test-strategy.md`
- `engineering/guardrails/policy-enforcement.md`
- `specifications/05-agent-contracts.md`
- `specifications/07-definition-of-done.md`

**Status:** Proposed shared observability standard.

**Scope:** Defines common instrumentation and event requirements. Production monitoring infrastructure, alert thresholds, and retention settings require deployment-specific decisions.
