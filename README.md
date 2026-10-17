# resolve-agent

Ecommerce customer-support agent in pure Python: policy engine, guardrails, evals, observability.

Scope: returns, exchanges, where is my order.

## Dev setup

Requires [uv](https://docs.astral.sh/uv/).

```bash
uv sync                 # create .venv, install deps from uv.lock
uv run pytest
uv run ruff check .
uv run mypy
```

Add dependencies with `uv add <pkg>` (runtime) or `uv add --dev <pkg>` (dev).

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

## Database (step 1)

SQLite via the standard library, integer cents for money, constraints enforced by the schema.

```bash
uv run python -m resolve_agent.domain.seed   # dev only: recreates data/resolve.db with edge-case data
sqlite3 data/resolve.db "select id, status, total_cents from orders"
```
