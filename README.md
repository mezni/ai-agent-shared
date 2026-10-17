# resolve-agent

Ecommerce customer-support agent in pure Python: policy engine, guardrails, evals, observability.

Scope: returns, exchanges, where is my order.

## Dev setup

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pytest
ruff check .
mypy
```

## Layout

| Package | Responsibility |
|---|---|
| `domain/` | Entities and repositories (SQLite) |
| `policy/` | Business rules as pure functions |
| `tools/` | Typed, validated actions the agent can call |
| `agent/` | Router, agent loop, memory |
| `guardrails/` | Input and output safety checks |
| `obs/` | Tracing, logging, metrics |
| `evals/` | Golden sets, graders, reports |
