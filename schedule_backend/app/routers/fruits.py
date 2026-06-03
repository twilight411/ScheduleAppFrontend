"""
果实收藏接口 — 果实墙展示
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth import get_current_user
from app.models.user import User
from app.schemas.common import success_response, error_response
from app.services.fruit_service import FruitService, get_fruit_type

router = APIRouter(prefix="/fruits", tags=["Fruits"])


@router.get("/collection")
async def get_collection(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """果实收藏墙 — 返回用户所有历史月度果实。"""
    svc = FruitService(db)
    fruits = await svc.get_collection(current_user.id)

    collection = []
    for f in fruits:
        fruit_info = get_fruit_type(f.overall_score)
        collection.append({
            "month": f.month,
            "fruit_type": f.fruit_type,
            "fruit_name": f.fruit_name,
            "fruit_emoji": fruit_info.get("emoji", ""),
            "fruit_rarity": f.fruit_rarity,
            "fruit_description": fruit_info.get("description", ""),
            "overall_score": f.overall_score,
            "weekly_scores": f.weekly_scores,
            "spirit_monthly": f.spirit_monthly,
            "best_spirit": f.best_spirit,
            "weakest_spirit": f.weakest_spirit,
            "awards": f.awards,
            "monthly_narrative": f.monthly_narrative,
        })

    return success_response(data={
        "total": len(collection),
        "fruits": collection,
    })


@router.get("/image")
async def get_fruit_image(
    month: str = Query(None, description="月份 YYYY-MM"),
    refresh: bool = Query(False, description="强制重新生图"),
    wait: bool = Query(
        True,
        description="false 时立即返回占位图并后台生图，请轮询 /image/status",
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取月度果实图像（支持异步生图）。"""
    svc = FruitService(db)

    if not month:
        from datetime import datetime
        today = datetime.now()
        month = f"{today.year}-{str(today.month).zfill(2)}"
    elif len(month) != 7 or month[4] != "-":
        raise HTTPException(
            400,
            detail=error_response("VALIDATION_ERROR", "月份格式错误，应为 YYYY-MM"),
        )

    fruit = await svc.get_fruit(current_user.id, month)
    if not fruit:
        fruit = await svc.generate_monthly_fruit(current_user.id, month)

    fruit_info = get_fruit_type(fruit.overall_score)
    spirit_monthly = fruit.spirit_monthly or {}
    meta = spirit_monthly.get("_meta") if isinstance(spirit_monthly, dict) else None
    theme_history = meta.get("theme_history") if isinstance(meta, dict) else None

    image_url, cached, status = await svc.get_or_generate_fruit_image(
        user_id=current_user.id,
        fruit=fruit,
        fruit_info=fruit_info,
        refresh=refresh,
        theme_history=theme_history,
        wait=wait if not refresh else True,
    )

    return success_response(data={
        "month": fruit.month,
        "fruit_type": fruit.fruit_type,
        "fruit_name": fruit.fruit_name,
        "fruit_rarity": fruit.fruit_rarity,
        "overall_score": fruit.overall_score,
        "best_spirit": fruit.best_spirit,
        "image_url": image_url,
        "cached": cached,
        "status": status,
    })


@router.get("/image/status")
async def get_fruit_image_status(
    month: str = Query(None, description="月份 YYYY-MM"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """轮询月度果实生图状态。"""
    if not month:
        from datetime import datetime
        today = datetime.now()
        month = f"{today.year}-{str(today.month).zfill(2)}"
    svc = FruitService(db)
    payload = await svc.get_fruit_image_status(current_user.id, month)
    return success_response(data=payload)
