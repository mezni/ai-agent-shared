# Portfolio Readiness Review

**Portfolio:** AI Customer Support & Ticket Resolution Agent  
**Repository:** `ai-agent-shared`  
**Status:** Conditionally ready  
**Review type:** Documentation-based architecture and engineering readiness review  
**Implementations:** `ai-agent-py`, `ai-agent-lc`, `ai-agent-rs`

## 1. Objective

Before implementing three versions of the AI Customer Support & Ticket Resolution Agent, perform a final architecture and engineering readiness review.

The purpose is to establish that:

- The shared specifications are sufficiently complete.
- The three implementations follow the same domain contracts and business policies.
- Architecture decisions are consistent.
- Security, guardrails, evaluation, and observability requirements are documented.
- Implementation-specific technology choices are clear.
- Outstanding risks and blockers are visible before coding begins.

**Important:** This is a documentation-based review of the decisions and artifacts established in the roadmap. It does not prove that the local repository contains every file or that all documents have passed automated validation. Those conditions must be verified locally.

## 2. Readiness Review

The following table records the current documented status.

| Area | Status | Review |
|---|---|---|
| Project scope | Ready | Initial scope and exclusions defined |
| Functional requirements | Ready | Requirements documented |
| Use cases | Ready | Core workflows documented |
| Domain model | Ready | Entities, policies, and invariants defined |
| Agent contracts | Action required | Verify vocabulary against evaluation datasets |
| Clean Architecture | Ready | Dependency Rule and layer responsibilities defined |
| Modular Monolith | Ready | Architecture decision recorded |
| Agent orchestration | Ready | Three implementation strategies documented |
| Business policies | Ready | Refund rules and approval requirements defined |
| Guardrails | Ready | Validation and enforcement standards documented |
| Security | Ready | Threat model, access control, and data protection documented |
| Evaluation | Ready | Datasets, schema, metrics, and protocol defined |
| Observability | Ready | Logging, tracing, and metrics strategy defined |
| Testing | Ready | Test strategy and quality gates defined |
| Python implementation | Ready | Technology and architecture plan defined |
| LangChain implementation | Ready | LangChain and LangGraph plan defined |
| Rust implementation | Action required | Validate Rig and RustView versions and APIs during setup |
| Deployment | Ready | Initial deployment approach documented |
| Performance baselines | Deferred | Measure after implementation |

## 3. Critical Consistency Checks

### 3.1 Domain Contracts versus Evaluation Datasets

**Readiness blocker**

The evaluation datasets introduced proposed vocabulary for:

- Agent intents.
- Ticket categories.
- Tool names.
- Tool-selection decisions.

These labels must be reconciled with the canonical definitions in:

```text
specifications/
├── 04-domain-model.md
└── 05-agent-contracts.md
```

Review these datasets:

```text
evaluation/datasets/
├── classification.json
├── tool-selection.json
├── policy-compliance.json
└── adversarial-cases.json
```

**Required action:**

1. Extract the canonical `AgentIntent` values from the domain model.
2. Extract the canonical ticket category values.
3. Extract the tool names from the agent contracts.
4. Compare each evaluation dataset against those definitions.
5. Record and resolve every mismatch.
6. Update the affected datasets or contracts through an explicit decision.
7. Add validation to prevent future vocabulary drift.

Do not silently modify the domain model or agent contracts just to make the datasets pass.

### 3.2 Architecture Consistency

All three implementations must follow the same architectural rules.

**Authoritative architecture:** Modular Monolith + Clean Architecture.

- **Frameworks and Drivers** — External frameworks, UI, files, providers.
- **Interface Adapters** — Controllers, presenters, repository and service implementations.
- **Use Cases** — Application workflows and application interfaces.
- **Entities** — Domain rules, entities and business invariants.

Source-code dependencies point inward.

The domain must not depend on LangChain, LangGraph, Rig, Streamlit, RustView, or infrastructure libraries.

### 3.3 Business Policy Consistency

The following rules must remain consistent across all implementations.

| Policy | Authoritative rule |
|---|---|
| Return window | 30 calendar days |
| Maximum refund | CAD 100 |
| Damaged goods | Image verification required |
| Refund eligibility | Deterministic domain decision |
| Sensitive recommendation | Human approval required |
| Financial execution | Excluded from initial scope |

The LLM can interpret a request and propose a recommendation. It cannot override the deterministic policy decision.

### 3.4 Implementation Consistency

| Repository | Architecture and technology |
|---|---|
| `ai-agent-py` | Plain Python, custom orchestrator, Streamlit |
| `ai-agent-lc` | LangChain, LangGraph, Streamlit |
| `ai-agent-rs` | Rust, Rig, custom orchestrator, RustView |

All three implementations must consume the same shared specifications, contracts, policy definitions, and evaluation datasets.

## 4. Implementation Boundaries

The initial portfolio release deliberately limits operational capabilities.

| Capability | Initial decision |
|---|---|
| Customer/order lookup | Synthetic JSON fixtures |
| Persistence | No database |
| Repository implementations | In-memory or fixture-backed |
| Approval persistence | In-memory |
| LangGraph checkpointing | In-memory initially |
| LLM provider | Provider abstraction |
| Real customer information | Not permitted |
| Real financial transactions | Not permitted |
| Autonomous refunds | Not permitted |
| Production CRM integration | Not included |

**Important trade-off:** In-memory approval and checkpointing are suitable for demonstrating workflows, but they do not provide durable recovery across process restarts. Document this limitation in each implementation.

## 5. Final Go/No-Go Checklist

Complete this checklist before starting implementation.

### Readiness Checklist (0/10)

- [ ] **Shared specifications are present and reviewed** — Verify `specifications/`.
- [ ] **Architecture documents agree with the ADRs** — Review `architecture/` and `architecture/decisions/`.
- [ ] **Canonical domain vocabulary is reconciled with evaluation datasets** — Resolve the critical consistency blocker.
- [ ] **Agent contracts define canonical tool names and schemas** — Review `specifications/05-agent-contracts.md`.
- [ ] **Business policies are consistent across specifications and datasets** — Check 30 days, CAD 100, and image verification.
- [ ] **Evaluation JSON Schema validates successfully** — Run JSON Schema validation.
- [ ] **Evaluation protocol and metrics agree** — Review `engineering/evaluation/`.
- [ ] **Security and guardrail requirements are documented** — Review `engineering/security/` and `engineering/guardrails/`.
- [ ] **All three implementation plans agree with shared requirements** — Review `implementations/`.
- [ ] **Local repository contents and Git state are verified** — Run the repository checks below.

Check each item only after verifying it in the repository.

## 6. Local Verification Commands

From the root of `ai-agent-shared`, run:

```bash
# Verify the working tree
git status

# Review the repository structure
find . -maxdepth 4 -type f | sort

# Validate the shared synthetic dataset
python -m json.tool evaluation/datasets/synthetic-data.json

# Validate all evaluation datasets as JSON
python -m json.tool evaluation/datasets/classification.json
python -m json.tool evaluation/datasets/tool-selection.json
python -m json.tool evaluation/datasets/policy-compliance.json
python -m json.tool evaluation/datasets/adversarial-cases.json

# Validate the evaluation result schema
uvx check-jsonschema evaluation/schemas/evaluation-result.schema.json
```

The JSON checks establish syntactic validity, not semantic agreement with the domain contracts. That agreement requires the vocabulary reconciliation described above.

## 7. Readiness Decision

**Conditionally ready.**

The portfolio has a documented architecture, engineering standards, datasets, evaluation contract, and implementation plans.

However, two actions remain before implementation:

1. Reconcile the canonical domain and agent contract vocabulary with the evaluation datasets.
2. Verify the actual repository contents and validate the shared artifacts locally.

The Rust implementation also has a technology compatibility check scheduled for its setup stage. That is a planned implementation task, not a reason to change the selected architecture.

**Gate decision:** Stage 6 may begin after the two readiness actions above are resolved. Do not treat the completion of this document as proof that those checks have passed.
