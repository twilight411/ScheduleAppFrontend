"""AI 相关接口"""
import logging
from typing import Any

from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import config
from app.db.session import get_db
from app.repositories.usage_repository import UsageRepository
from app.services.schedule_ai import run_chat_with_schedules

router = APIRouter(prefix="/ai", tags=["AI"])
logger = logging.getLogger(__name__)


def _usage_fallback_for_db() -> dict[str, Any]:
    """大模型响应未带 usage 时仍写入一条用量记录（token 为 0），并照常可挂对话原文"""
    provider = config.get_ai_provider()
    if provider == "minimax":
        model = "M2-her"
    elif provider == "deepseek":
        model = "deepseek-chat"
    else:
        model = "gpt-3.5-turbo"
    return {
        "provider": provider,
        "model": model,
        "prompt_tokens": 0,
        "completion_tokens": 0,
        "total_tokens": 0,
    }


class ChatRequest(BaseModel):
    """聊天请求 - 与 Flutter RemoteAIChatRepository 对齐"""
    message: str = Field(..., min_length=1, description="用户消息")
    spiritType: str | None = Field(None, description="精灵类型: light/water/soil/air/nutrition")
    isGroupChat: bool = Field(False, description="是否群聊模式")
    userId: str | None = Field(None, description="用户 ID，用于用量统计")
    clientNowIso: str | None = Field(
        None,
        description="客户端当前时间 ISO8601，便于 AI 理解「明天」「下午」并生成正确日程时间",
    )


class ChatResponse(BaseModel):
    """聊天响应"""
    response: str = Field(..., description="AI 回复文本（已去掉 MiniMax 内部日程标记块）")
    createdTasks: list[dict[str, Any]] = Field(
        default_factory=list,
        description="本次对话新创建的日程，结构与 Flutter Task.toJson 一致，可直接 addTask",
    )


@router.post("/chat", response_model=ChatResponse)
async def ai_chat(
    req: ChatRequest,
    x_user_id: str | None = Header(None, alias="X-User-Id"),
    db: AsyncSession = Depends(get_db),
) -> ChatResponse:
    """
    AI 聊天接口
    Flutter 调用: POST /api/ai/chat
    可选 Header: X-User-Id 或 body.userId 用于用量统计
    """
    user_id = req.userId or x_user_id or "anonymous"
    try:
        text, created_tasks, usage, llm_raw_json = await run_chat_with_schedules(
            db,
            user_id,
            req.message,
            req.spiritType,
            req.isGroupChat,
            req.clientNowIso,
        )
        # 每次成功对话写一条 usage_logs；对话正文由 USAGE_LOG_INCLUDE_CONVERSATION 控制（默认写入）
        try:
            repo = UsageRepository(db)
            usage_for_db = usage if usage is not None else _usage_fallback_for_db()
            inc = config.USAGE_LOG_INCLUDE_CONVERSATION
            await repo.create(
                user_id,
                usage_for_db,
                user_message=req.message if inc else None,
                assistant_message=text if inc else None,
                llm_response_json=llm_raw_json,
            )
        except Exception as db_err:
            logger.warning("用量记录失败（不影响回复）: %s", db_err)
        return ChatResponse(response=text, createdTasks=created_tasks)
    except ValueError as e:
        logger.exception("AI 参数错误")
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        logger.exception("AI 调用失败")
        raise HTTPException(status_code=500, detail=str(e))
