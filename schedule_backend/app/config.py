"""配置管理"""
import os
from pathlib import Path

from dotenv import load_dotenv

# 加载 .env
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(env_path)


class Config:
    """应用配置"""

    # AI API（按优先级：MiniMax > DeepSeek > OpenAI）
    MINIMAX_API_KEY: str = os.getenv("MINIMAX_API_KEY", "")
    MINIMAX_BASE_URL: str = os.getenv("MINIMAX_BASE_URL", "https://api.minimax.io")
    DEEPSEEK_API_KEY: str = os.getenv("DEEPSEEK_API_KEY", "")
    DEEPSEEK_BASE_URL: str = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")

    # PostgreSQL（需安装 pgvector 扩展）
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql+asyncpg://postgres:postgres@localhost:5432/schedule_app",
    )

    # 服务
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))

    # 每次成功 /ai/chat 是否在 usage_logs 里同时写入本轮「用户原话 + AI 全文」（默认 true）
    # 生产环境涉及隐私时请设为 false
    USAGE_LOG_INCLUDE_CONVERSATION: bool = os.getenv(
        "USAGE_LOG_INCLUDE_CONVERSATION", "true"
    ).strip().lower() in ("1", "true", "yes", "on")

    # 用量记录是否附带「提供商完整响应」JSON 字符串（管理台可折叠查看；体量大时可关）
    USAGE_LOG_INCLUDE_LLM_RAW: bool = os.getenv(
        "USAGE_LOG_INCLUDE_LLM_RAW", "true"
    ).strip().lower() in ("1", "true", "yes", "on")

    @classmethod
    def get_ai_provider(cls) -> str:
        """返回当前使用的 AI 提供商"""
        if cls.MINIMAX_API_KEY:
            return "minimax"
        if cls.DEEPSEEK_API_KEY:
            return "deepseek"
        if cls.OPENAI_API_KEY:
            return "openai"
        raise ValueError("请配置 MINIMAX_API_KEY、DEEPSEEK_API_KEY 或 OPENAI_API_KEY")

    @classmethod
    def get_ai_client_config(cls) -> tuple[str, str, str]:
        """返回 (provider, api_key, base_url)"""
        if cls.MINIMAX_API_KEY:
            return "minimax", cls.MINIMAX_API_KEY, cls.MINIMAX_BASE_URL
        if cls.DEEPSEEK_API_KEY:
            return "deepseek", cls.DEEPSEEK_API_KEY, cls.DEEPSEEK_BASE_URL
        if cls.OPENAI_API_KEY:
            return "openai", cls.OPENAI_API_KEY, "https://api.openai.com/v1"
        raise ValueError("请配置 MINIMAX_API_KEY、DEEPSEEK_API_KEY 或 OPENAI_API_KEY")


config = Config()
