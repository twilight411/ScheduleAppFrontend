"""用量记录仓储"""
from datetime import datetime, timedelta, timezone
from typing import Any

from sqlalchemy import Date, cast, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import UsageLog


class UsageRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def create(
        self,
        user_id: str,
        usage: dict[str, Any],
        *,
        user_message: str | None = None,
        assistant_message: str | None = None,
        llm_response_json: str | None = None,
    ) -> UsageLog:
        log = UsageLog(
            user_id=user_id,
            provider=usage.get("provider", ""),
            model=usage.get("model", ""),
            prompt_tokens=usage.get("prompt_tokens", 0),
            completion_tokens=usage.get("completion_tokens", 0),
            total_tokens=usage.get("total_tokens", 0),
            user_message=user_message,
            assistant_message=assistant_message,
            llm_response_json=llm_response_json,
        )
        self._session.add(log)
        await self._session.flush()
        return log

    async def get_stats(self, days: int = 7) -> dict[str, Any]:
        """汇总用量统计"""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        total = await self._session.execute(
            select(
                func.coalesce(func.sum(UsageLog.total_tokens), 0).label("total"),
                func.coalesce(func.sum(UsageLog.prompt_tokens), 0).label("prompt"),
                func.coalesce(func.sum(UsageLog.completion_tokens), 0).label("completion"),
                func.count(UsageLog.id).label("requests"),
            ).where(UsageLog.created_at >= since)
        )
        row = total.one()
        return {
            "total_tokens": int(row[0]),
            "prompt_tokens": int(row[1]),
            "completion_tokens": int(row[2]),
            "request_count": int(row[3]),
            "days": days,
        }

    async def get_by_user(self, days: int = 7) -> list[dict[str, Any]]:
        """按用户汇总"""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        result = await self._session.execute(
            select(
                UsageLog.user_id,
                func.coalesce(func.sum(UsageLog.total_tokens), 0).label("total_tokens"),
                func.count(UsageLog.id).label("request_count"),
            )
            .where(UsageLog.created_at >= since)
            .group_by(UsageLog.user_id)
            .order_by(func.sum(UsageLog.total_tokens).desc())
        )
        return [
            {"user_id": r[0], "total_tokens": int(r[1]), "request_count": int(r[2])}
            for r in result.all()
        ]

    async def get_daily_trend(self, days: int = 7) -> list[dict[str, Any]]:
        """按日汇总（PostgreSQL 兼容）"""
        since = datetime.now(timezone.utc) - timedelta(days=days)
        date_col = cast(UsageLog.created_at, Date)

        result = await self._session.execute(
            select(
                date_col.label("date"),
                func.coalesce(func.sum(UsageLog.total_tokens), 0).label("total_tokens"),
                func.count(UsageLog.id).label("request_count"),
            )
            .where(UsageLog.created_at >= since)
            .group_by(date_col)
            .order_by(date_col)
        )
        return [
            {"date": str(r[0]), "total_tokens": int(r[1]), "request_count": int(r[2])}
            for r in result.all()
        ]

    async def list_logs_for_user(
        self,
        user_id: str,
        days: int = 7,
        limit: int = 500,
    ) -> list[dict[str, Any]]:
        """单用户每次请求的明细（含创建时间，用于管理台精确到秒）"""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        result = await self._session.execute(
            select(UsageLog)
            .where(UsageLog.user_id == user_id, UsageLog.created_at >= since)
            .order_by(UsageLog.created_at.desc())
            .limit(limit)
        )
        rows: list[dict[str, Any]] = []
        for log in result.scalars().all():
            rows.append(
                {
                    "id": log.id,
                    "created_at": log.created_at.isoformat() if log.created_at else None,
                    "provider": log.provider,
                    "model": log.model,
                    "prompt_tokens": log.prompt_tokens,
                    "completion_tokens": log.completion_tokens,
                    "total_tokens": log.total_tokens,
                    "user_message": log.user_message,
                    "assistant_message": log.assistant_message,
                    "llm_response_json": log.llm_response_json,
                }
            )
        return rows
