"""日程任务仓储"""
from datetime import datetime, timedelta, timezone
from typing import Any

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import ScheduleTask

_VALID_CATEGORIES = frozenset({"light", "water", "soil", "air", "nutrition"})
_VALID_REPEATS = frozenset({"never", "daily", "weekly", "monthly"})


def _parse_iso_datetime(s: str) -> datetime:
    raw = (s or "").strip().replace("Z", "+00:00")
    # Dart 可能输出 +0800，Python 需要 +08:00
    if len(raw) >= 5 and raw[-5] in "+-" and raw[-3] != ":" and raw[-2:].isdigit():
        raw = raw[:-2] + ":" + raw[-2:]
    dt = datetime.fromisoformat(raw)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)


def _utc_ms(dt: datetime) -> int:
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return int(dt.timestamp() * 1000)


class ScheduleRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def create_from_tool_items(
        self, user_id: str, items: list[dict[str, Any]]
    ) -> list[dict[str, Any]]:
        """由 AI 工具参数创建多条日程，返回 Flutter Task.fromJson 兼容字典列表"""
        out: list[dict[str, Any]] = []
        for raw in items[:30]:
            if not isinstance(raw, dict):
                continue
            title = str(raw.get("title") or "").strip()[:256]
            if not title:
                continue
            desc = str(raw.get("description") or "")[:4000]
            try:
                start = _parse_iso_datetime(str(raw.get("start_iso") or ""))
                end = _parse_iso_datetime(str(raw.get("end_iso") or ""))
            except (ValueError, TypeError):
                continue
            if end <= start:
                end = start + timedelta(hours=1)
            cat = str(raw.get("category") or "light").lower()
            if cat not in _VALID_CATEGORIES:
                cat = "light"
            rep = str(raw.get("repeat") or raw.get("repeat_option") or "never").lower()
            if rep not in _VALID_REPEATS:
                rep = "never"
            is_all = bool(raw.get("is_all_day", False))

            row = ScheduleTask(
                user_id=user_id,
                title=title,
                description=desc,
                start_at=start,
                end_at=end,
                category=cat,
                repeat_option=rep,
                is_all_day=is_all,
            )
            self._session.add(row)
            await self._session.flush()
            out.append(
                {
                    "id": row.id,
                    "title": row.title,
                    "description": row.description,
                    "startDate": _utc_ms(row.start_at),
                    "endDate": _utc_ms(row.end_at),
                    "category": row.category,
                    "repeatOption": row.repeat_option,
                    "isAllDay": row.is_all_day,
                }
            )
        return out

    async def list_for_user(self, user_id: str, limit: int = 500) -> list[dict[str, Any]]:
        result = await self._session.execute(
            select(ScheduleTask)
            .where(ScheduleTask.user_id == user_id)
            .order_by(ScheduleTask.start_at.desc())
            .limit(limit)
        )
        rows = []
        for row in result.scalars().all():
            rows.append(
                {
                    "id": row.id,
                    "title": row.title,
                    "description": row.description,
                    "startDate": _utc_ms(row.start_at),
                    "endDate": _utc_ms(row.end_at),
                    "category": row.category,
                    "repeatOption": row.repeat_option,
                    "isAllDay": row.is_all_day,
                }
            )
        return rows
