"""数据库模型 - 支持 pgvector 向量存储"""
from datetime import datetime
from typing import Optional

from pgvector.sqlalchemy import Vector
from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.session import Base


class User(Base):
    """用户表"""
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(64), primary_key=True)  # device_id 或 uuid
    nickname: Mapped[Optional[str]] = mapped_column(String(128), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    def __repr__(self) -> str:
        return f"<User(id={self.id})>"


class ChatMessage(Base):
    """聊天记录 - 用于上下文压缩、多轮对话"""
    __tablename__ = "chat_messages"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    role: Mapped[str] = mapped_column(String(16), nullable=False)  # user / assistant / system
    content: Mapped[str] = mapped_column(Text, nullable=False)
    spirit_type: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    def __repr__(self) -> str:
        return f"<ChatMessage(id={self.id}, user_id={self.user_id}, role={self.role})>"


class UserPreference(Base):
    """
    用户偏好 - 用于 RAG 检索、个性化
    embedding 为向量，维度需与 embedding 模型一致（如 1536 for OpenAI text-embedding-3-small）
    """
    __tablename__ = "user_preferences"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False)
    category: Mapped[str] = mapped_column(String(64), nullable=False)  # 如: schedule_habit, interest, constraint
    content: Mapped[str] = mapped_column(Text, nullable=False)  # 偏好描述文本
    embedding: Mapped[Optional[list[float]]] = mapped_column(Vector(1536), nullable=True)  # pgvector，可后续 RAG 扩展
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class UsageLog(Base):
    """Token 用量记录"""
    __tablename__ = "usage_logs"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(64), index=True, nullable=False)  # 匿名用 "anonymous"
    provider: Mapped[str] = mapped_column(String(32), nullable=False)  # minimax / deepseek / openai
    model: Mapped[str] = mapped_column(String(64), nullable=False)
    prompt_tokens: Mapped[int] = mapped_column(nullable=False, default=0)
    completion_tokens: Mapped[int] = mapped_column(nullable=False, default=0)
    total_tokens: Mapped[int] = mapped_column(nullable=False, default=0)
    # 由 USAGE_LOG_INCLUDE_CONVERSATION 控制是否写入本轮用户输入与 AI 回复全文
    user_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    assistant_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    # 管理台可折叠查看：提供商返回的完整 JSON（字符串，自行 json.loads）
    llm_response_json: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class ScheduleTask(Base):
    """用户日程项（AI 工具创建或后续扩展手动同步）"""

    __tablename__ = "schedule_tasks"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(64), index=True, nullable=False)
    title: Mapped[str] = mapped_column(String(256), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False, default="")
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    category: Mapped[str] = mapped_column(String(32), nullable=False, default="light")
    repeat_option: Mapped[str] = mapped_column(String(32), nullable=False, default="never")
    is_all_day: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
