import sqlite3
from collections.abc import Iterator
from datetime import UTC, date, datetime

import pytest

from resolve_agent.domain.clock import Clock
from resolve_agent.domain.db import connect, init_schema
from resolve_agent.domain.seed import seed

TODAY = date(2026, 10, 16)


@pytest.fixture
def conn() -> Iterator[sqlite3.Connection]:
    c = connect(":memory:")
    init_schema(c)
    yield c
    c.close()


@pytest.fixture
def seeded(conn: sqlite3.Connection) -> sqlite3.Connection:
    seed(conn, TODAY)
    return conn


@pytest.fixture
def clock() -> Clock:
    return lambda: datetime(2026, 10, 16, 12, 0, tzinfo=UTC)
