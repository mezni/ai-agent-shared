"""Typed, immutable application settings loaded from environment variables.

Business policy values (return window, refund limit) are deliberately NOT
overridable from the environment: they are versioned code, reviewed like code.
"""

from __future__ import annotations

import os
from collections.abc import Mapping
from dataclasses import dataclass, field
from decimal import Decimal

VALID_ENVS = ("dev", "staging", "prod")


@dataclass(frozen=True)
class PolicySettings:
    return_window_days: int = 30
    auto_refund_limit: Decimal = Decimal("50")
    exchangeable_categories: frozenset[str] = frozenset({"apparel", "footwear", "accessories"})


@dataclass(frozen=True)
class LLMSettings:
    api_key: str = field(default="", repr=False)
    router_model: str = "claude-haiku-5-5"
    agent_model: str = "claude-sonnet-5-5"
    timeout_s: float = 10.0


@dataclass(frozen=True)
class Settings:
    env: str = "dev"
    db_path: str = "data/resolve.db"
    log_level: str = "INFO"
    log_json: bool = True
    trace_path: str = "traces/spans.jsonl"  # empty string disables the JSONL trace file
    policy: PolicySettings = field(default_factory=PolicySettings)
    llm: LLMSettings = field(default_factory=LLMSettings)

    @classmethod
    def from_env(cls, environ: Mapping[str, str] | None = None) -> Settings:
        e = os.environ if environ is None else environ
        defaults = cls()

        env = e.get("RESOLVE_ENV", defaults.env)
        if env not in VALID_ENVS:
            raise ValueError(f"RESOLVE_ENV must be one of {VALID_ENVS}, got {env!r}")

        api_key = e.get("ANTHROPIC_API_KEY", "")
        if env == "prod" and not api_key:
            raise ValueError("ANTHROPIC_API_KEY is required when RESOLVE_ENV=prod")

        llm = LLMSettings(
            api_key=api_key,
            router_model=e.get("RESOLVE_ROUTER_MODEL", defaults.llm.router_model),
            agent_model=e.get("RESOLVE_AGENT_MODEL", defaults.llm.agent_model),
            timeout_s=float(e.get("RESOLVE_LLM_TIMEOUT_S", defaults.llm.timeout_s)),
        )
        return cls(
            env=env,
            db_path=e.get("RESOLVE_DB_PATH", defaults.db_path),
            log_level=e.get("RESOLVE_LOG_LEVEL", defaults.log_level).upper(),
            log_json=e.get("RESOLVE_LOG_JSON", "1").lower() not in {"0", "false", "no"},
            trace_path=e.get("RESOLVE_TRACE_PATH", defaults.trace_path),
            llm=llm,
        )
