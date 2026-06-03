"""
生命树接口 — 周树数据 + 历史趋势
"""
from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_user
from app.models.user import User
from app.schemas.common import success_response, error_response
from app.services.tree_service import TreeService

router = APIRouter(prefix="/tree", tags=["Tree"])


def _parse_week_start(week_start: str | None) -> date:
    if not week_start:
        today = datetime.now(timezone.utc).date()
        return today - timedelta(days=today.weekday())
    try:
        return datetime.strptime(week_start, "%Y-%m-%d").date()
    except ValueError:
        raise HTTPException(
            400, detail=error_response("VALIDATION_ERROR", "日期格式错误")
        )


@router.get("/weekly")
async def get_weekly_tree(
    week_start: str = Query(None, description="周一日期 YYYY-MM-DD"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    获取周生命树数据（快速路径：先返回雷达/得分，AI 叙述后台生成）。
    """
    svc = TreeService(db)
    ws = _parse_week_start(week_start)

    tree_data = await svc.build_tree_data(current_user.id, ws, fast=True)
    if tree_data.get("ai_enrichment") == "pending":
        svc.schedule_ai_enrichment(current_user.id, ws)

    return success_response(data=tree_data)


@router.get("/weekly/enrichment")
async def get_weekly_tree_enrichment(
    week_start: str = Query(None, description="周一日期 YYYY-MM-DD"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """轮询 AI 树叙述与精灵点评是否就绪。"""
    svc = TreeService(db)
    ws = _parse_week_start(week_start)
    payload = await svc.get_enrichment_payload(current_user.id, ws)
    return success_response(data=payload)


@router.get("/history")
async def get_tree_history(
    months: int = Query(3, ge=1, le=12, description="查看最近N个月"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """生命树历史趋势"""
    svc = TreeService(db)
    history = await svc.get_tree_history(current_user.id, months)
    return success_response(data={"history": history, "months": months})


@router.get("/weekly/image")
async def get_weekly_tree_image(
    week_start: str = Query(None, description="周一日期 YYYY-MM-DD"),
    refresh: bool = Query(False, description="为 true 时忽略缓存并重新生图"),
    wait: bool = Query(
        True,
        description="false 时立即返回占位图并后台生图，请轮询 /weekly/image/status",
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取周生命树图像（支持异步生图）。"""
    svc = TreeService(db)
    ws = _parse_week_start(week_start)

    tree_data = await svc.build_tree_data(
        current_user.id, ws, include_narrative=False, fast=True
    )
    branches = tree_data.get("branches") or []
    overall = float(tree_data.get("overall_score") or 0)
    tree_health = tree_data.get("tree_health") or ""
    season = tree_data.get("season_label") or ""

    if refresh:
        from sqlalchemy import delete
        from app.models.report import WeeklyTreeImage

        await db.execute(
            delete(WeeklyTreeImage).where(
                WeeklyTreeImage.user_id == current_user.id,
                WeeklyTreeImage.week_start == ws,
            )
        )
        await db.flush()

    image_url, cached, status = await svc.get_or_generate_weekly_tree_image(
        user_id=current_user.id,
        week_start=ws,
        branches=branches,
        overall=overall,
        tree_health=tree_health,
        season=season,
        wait=wait if not refresh else True,
    )

    return success_response(
        data={
            "week_start": str(ws),
            "overall_score": overall,
            "tree_health": tree_health,
            "season_label": season,
            "image_url": image_url,
            "cached": cached,
            "status": status,
        }
    )


@router.get("/weekly/image/status")
async def get_weekly_tree_image_status(
    week_start: str = Query(None, description="周一日期 YYYY-MM-DD"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """轮询生命树生图状态。"""
    svc = TreeService(db)
    ws = _parse_week_start(week_start)
    payload = await svc.get_tree_image_status(current_user.id, ws)
    return success_response(data=payload)
