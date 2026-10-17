import dataclasses
from decimal import Decimal

import pytest

from resolve_agent.config import Settings


def test_defaults() -> None:
    s = Settings.from_env({})
    assert s.env == "dev"
    assert s.policy.return_window_days == 30
    assert s.policy.auto_refund_limit == Decimal("50")


def test_env_overrides() -> None:
    s = Settings.from_env(
        {"RESOLVE_ENV": "staging", "RESOLVE_LOG_LEVEL": "debug", "RESOLVE_DB_PATH": "/tmp/x.db"}
    )
    assert s.env == "staging"
    assert s.log_level == "DEBUG"
    assert s.db_path == "/tmp/x.db"


def test_policy_is_not_overridable_from_env() -> None:
    s = Settings.from_env({"RESOLVE_RETURN_WINDOW_DAYS": "365"})
    assert s.policy.return_window_days == 30


def test_invalid_env_rejected() -> None:
    with pytest.raises(ValueError, match="RESOLVE_ENV"):
        Settings.from_env({"RESOLVE_ENV": "production"})


def test_prod_requires_api_key() -> None:
    with pytest.raises(ValueError, match="ANTHROPIC_API_KEY"):
        Settings.from_env({"RESOLVE_ENV": "prod"})


def test_api_key_never_in_repr() -> None:
    s = Settings.from_env({"ANTHROPIC_API_KEY": "sk-secret"})
    assert "sk-secret" not in repr(s)


def test_settings_are_frozen() -> None:
    s = Settings.from_env({})
    with pytest.raises(dataclasses.FrozenInstanceError):
        s.env = "prod"  # type: ignore[misc]
