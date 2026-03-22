"""将大模型提供商原始响应打包为可入库的 JSON 字符串"""
from __future__ import annotations

import json
from typing import Any

from app.config import config

# PostgreSQL text 字段理论很大，仍做上限避免异常体积极端情况
_MAX_CHARS = 900_000


def pack_llm_raw_payload(payload: Any) -> str | None:
    """
    将任意可 JSON 序列化对象转为字符串写入 usage_logs。
    若关闭 USAGE_LOG_INCLUDE_LLM_RAW 则返回 None。
    """
    if not config.USAGE_LOG_INCLUDE_LLM_RAW:
        return None
    try:
        s = json.dumps(payload, ensure_ascii=False, default=str)
    except (TypeError, ValueError):
        return None
    if len(s) > _MAX_CHARS:
        return s[:_MAX_CHARS] + '\n... [truncated by server]'
    return s
