"""Fire-and-forget background jobs with a dedicated DB session."""
from __future__ import annotations

import asyncio
from collections.abc import Awaitable, Callable
from typing import Any

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import async_session_factory

logger = structlog.get_logger()

_running: set[str] = set()


async def run_background(
    job_key: str,
    coro_factory: Callable[[AsyncSession], Awaitable[Any]],
) -> bool:
    """
    Schedule a coroutine with its own session/commit.
    Returns False if the same job_key is already running.
    """
    if job_key in _running:
        return False
    _running.add(job_key)

    async def _wrapper() -> None:
        try:
            async with async_session_factory() as session:
                await coro_factory(session)
                await session.commit()
        except Exception as exc:
            logger.error(
                "background_task_failed",
                job_key=job_key,
                error=str(exc),
            )
        finally:
            _running.discard(job_key)

    asyncio.create_task(_wrapper())
    return True
