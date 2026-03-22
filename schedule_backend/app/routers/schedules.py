"""用户日程同步（与 Flutter 本地 Task 对齐的数据结构）"""
import logging

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.repositories.schedule_repository import ScheduleRepository

router = APIRouter(prefix="/schedules", tags=["Schedules"])
logger = logging.getLogger(__name__)


@router.get("")
async def list_my_schedules(
    x_user_id: str | None = Header(None, alias="X-User-Id"),
    userId: str | None = Query(None, description="与 Header 二选一"),
    limit: int = Query(200, ge=1, le=1000),
    db: AsyncSession = Depends(get_db),
):
    """拉取当前用户日程（毫秒时间戳 + category 等，与 Task.fromJson 兼容）"""
    uid = userId or x_user_id or "anonymous"
    try:
        repo = ScheduleRepository(db)
        return await repo.list_for_user(uid, limit=limit)
    except Exception as e:
        logger.exception("list_my_schedules 失败")
        raise HTTPException(status_code=500, detail=str(e))
