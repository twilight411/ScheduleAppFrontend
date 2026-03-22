"""后台管理 API"""
import logging

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.repositories.usage_repository import UsageRepository

router = APIRouter(prefix="/admin", tags=["Admin"])
logger = logging.getLogger(__name__)


@router.get("/usage/stats")
async def get_usage_stats(
    days: int = Query(7, ge=1, le=90),
    db: AsyncSession = Depends(get_db),
):
    """用量汇总"""
    try:
        repo = UsageRepository(db)
        return await repo.get_stats(days=days)
    except Exception as e:
        logger.exception("get_usage_stats 失败")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/usage/by-user")
async def get_usage_by_user(
    days: int = Query(7, ge=1, le=90),
    db: AsyncSession = Depends(get_db),
):
    """按用户用量排行"""
    try:
        repo = UsageRepository(db)
        return await repo.get_by_user(days=days)
    except Exception as e:
        logger.exception("get_usage_by_user 失败")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/usage/daily")
async def get_usage_daily(
    days: int = Query(7, ge=1, le=90),
    db: AsyncSession = Depends(get_db),
):
    """按日用量趋势"""
    try:
        repo = UsageRepository(db)
        return await repo.get_daily_trend(days=days)
    except Exception as e:
        logger.exception("get_usage_daily 失败")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/usage/user/{user_id}/logs")
async def get_usage_logs_for_user(
    user_id: str,
    days: int = Query(7, ge=1, le=90),
    limit: int = Query(500, ge=1, le=2000),
    db: AsyncSession = Depends(get_db),
):
    """单用户每次 AI 请求的明细（时间 ISO8601 含秒；对话正文仅对配置了保存的用户有值）"""
    try:
        repo = UsageRepository(db)
        return {
            "user_id": user_id,
            "days": days,
            "logs": await repo.list_logs_for_user(user_id, days=days, limit=limit),
        }
    except Exception as e:
        logger.exception("get_usage_logs_for_user 失败")
        raise HTTPException(status_code=500, detail=str(e))
