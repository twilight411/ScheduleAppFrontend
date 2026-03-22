"""AI 创建日程：OpenAI 兼容工具调用 + MiniMax 标记块解析"""
from __future__ import annotations

import asyncio
import json
import logging
from typing import Any

from openai import OpenAI
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import config
from app.repositories.schedule_repository import ScheduleRepository
from app.services.ai_service import _chat_minimax, get_system_prompt
from app.services.llm_log_utils import pack_llm_raw_payload

logger = logging.getLogger(__name__)

CREATE_SCHEDULE_TOOLS: list[dict[str, Any]] = [
    {
        "type": "function",
        "function": {
            "name": "create_schedule_items",
            "description": (
                "当用户明确要求创建、添加、安排日程或任务到日历/安排里时调用。"
                "结合用户设备当前时间理解「明天」「下午三点」等。"
                "时间必须用 ISO8601，建议带时区偏移（如 +08:00）。"
            ),
            "parameters": {
                "type": "object",
                "properties": {
                    "items": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "title": {"type": "string"},
                                "description": {"type": "string"},
                                "start_iso": {
                                    "type": "string",
                                    "description": "开始时间 ISO8601",
                                },
                                "end_iso": {"type": "string"},
                                "category": {
                                    "type": "string",
                                    "enum": ["light", "water", "soil", "air", "nutrition"],
                                },
                                "is_all_day": {"type": "boolean"},
                                "repeat": {
                                    "type": "string",
                                    "enum": ["never", "daily", "weekly", "monthly"],
                                },
                            },
                            "required": ["title", "start_iso", "end_iso", "category"],
                        },
                    }
                },
                "required": ["items"],
            },
        },
    }
]


def _schedule_time_hint(client_now_iso: str | None) -> str:
    if client_now_iso and client_now_iso.strip():
        return f"用户设备当前时间（理解「今天/明天」）：{client_now_iso.strip()}"
    return "用户设备当前时间未提供；输出时间请用 ISO8601 并尽量带时区偏移。"


MINIMAX_SCHEDULE_BLOCK = """
【日程写入-MiniMax】若用户明确要求把事件加入日程/安排/日历，在自然语言回复之后，必须另起一段输出（保持 JSON 一行或多行均可）：
<<<SCHEDULE_TOOL
{"items":[{"title":"标题","description":"","start_iso":"2026-02-13T09:00:00+08:00","end_iso":"2026-02-13T10:00:00+08:00","category":"light","is_all_day":false,"repeat":"never"}]}
>>>
category 只能是 light/water/soil/air/nutrition（学习/娱乐/健康/社交/兴趣）。repeat 为 never/daily/weekly/monthly。
无创建日程需求时不要输出此块。
""".strip()

OPENAI_SCHEDULE_HINT = """
【日程写入】用户若要求创建/添加/安排日程，你必须调用函数 create_schedule_items；不要只在文字里声称已添加而未调用工具。
""".strip()


def build_system_minimax(
    spirit_type: str | None, is_group_chat: bool, client_now_iso: str | None
) -> str:
    base = get_system_prompt(spirit_type, is_group_chat)
    return f"{base}\n\n{_schedule_time_hint(client_now_iso)}\n\n{MINIMAX_SCHEDULE_BLOCK}"


def build_system_openai(
    spirit_type: str | None, is_group_chat: bool, client_now_iso: str | None
) -> str:
    base = get_system_prompt(spirit_type, is_group_chat)
    return f"{base}\n\n{_schedule_time_hint(client_now_iso)}\n\n{OPENAI_SCHEDULE_HINT}"


def extract_minimax_schedule_block(content: str) -> tuple[str, list[dict[str, Any]] | None]:
    marker = "<<<SCHEDULE_TOOL"
    end_marker = ">>>"
    if marker not in content:
        return content, None
    idx = content.index(marker)
    before = content[:idx].rstrip()
    after_marker = content[idx + len(marker) :].lstrip()
    if not after_marker.startswith("{"):
        return content, None
    depth = 0
    end_json = -1
    for i, c in enumerate(after_marker):
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end_json = i + 1
                break
    if end_json <= 0:
        return before, None
    json_str = after_marker[:end_json]
    tail = after_marker[end_json:].lstrip()
    if tail.startswith(end_marker):
        tail = tail[len(end_marker) :].lstrip()
    items: list[dict[str, Any]] | None = None
    try:
        data = json.loads(json_str)
        raw_items = data.get("items")
        if isinstance(raw_items, list) and raw_items:
            items = [x for x in raw_items if isinstance(x, dict)]
    except json.JSONDecodeError:
        logger.warning("MiniMax 日程 JSON 解析失败: %s", json_str[:200])
    out_text = before
    if tail:
        out_text = f"{before}\n{tail}".strip()
    return out_text, items


def _merge_usage(a: dict[str, Any] | None, b: dict[str, Any] | None) -> dict[str, Any] | None:
    if not a:
        return b
    if not b:
        return a
    return {
        "provider": a.get("provider") or b.get("provider", ""),
        "model": a.get("model") or b.get("model", ""),
        "prompt_tokens": int(a.get("prompt_tokens", 0)) + int(b.get("prompt_tokens", 0)),
        "completion_tokens": int(a.get("completion_tokens", 0))
        + int(b.get("completion_tokens", 0)),
        "total_tokens": int(a.get("total_tokens", 0)) + int(b.get("total_tokens", 0)),
    }


def _assistant_message_to_dict(msg: Any) -> dict[str, Any]:
    d: dict[str, Any] = {"role": msg.role}
    if msg.content:
        d["content"] = msg.content
    tcs = getattr(msg, "tool_calls", None)
    if tcs:
        d["tool_calls"] = [
            {
                "id": tc.id,
                "type": "function",
                "function": {
                    "name": tc.function.name,
                    "arguments": tc.function.arguments or "{}",
                },
            }
            for tc in tcs
        ]
    return d


def _dump_openai_response(response: Any) -> dict[str, Any]:
    try:
        return response.model_dump(mode="json")
    except Exception:
        try:
            return response.model_dump()
        except Exception:
            return {"repr": repr(response)}


async def chat_openai_with_schedule_tools(
    api_key: str,
    base_url: str,
    model: str,
    system_prompt: str,
    user_message: str,
    db: AsyncSession,
    user_id: str,
) -> tuple[str, list[dict[str, Any]], dict[str, Any] | None, str | None]:
    client = OpenAI(api_key=api_key, base_url=base_url)
    messages: list[dict[str, Any]] = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_message},
    ]
    created_all: list[dict[str, Any]] = []
    total_usage: dict[str, Any] | None = None
    raw_rounds: list[dict[str, Any]] = []
    prov_label = "deepseek" if "deepseek" in base_url.lower() else "openai"
    max_rounds = 8

    for _ in range(max_rounds):
        def _call() -> Any:
            return client.chat.completions.create(
                model=model,
                messages=messages,
                tools=CREATE_SCHEDULE_TOOLS,
                tool_choice="auto",
            )

        response = await asyncio.to_thread(_call)
        raw_rounds.append(_dump_openai_response(response))
        if response.usage:
            prov = "deepseek" if "deepseek" in base_url.lower() else "openai"
            u = {
                "provider": prov,
                "model": response.model or model,
                "prompt_tokens": response.usage.prompt_tokens or 0,
                "completion_tokens": response.usage.completion_tokens or 0,
                "total_tokens": response.usage.total_tokens or 0,
            }
            total_usage = _merge_usage(total_usage, u)

        msg = response.choices[0].message
        tcs = getattr(msg, "tool_calls", None)
        if not tcs:
            text = (msg.content or "").strip()
            llm_raw = pack_llm_raw_payload(
                {
                    "provider": prov_label,
                    "model": model,
                    "rounds": raw_rounds,
                }
            )
            return text, created_all, total_usage, llm_raw

        messages.append(_assistant_message_to_dict(msg))
        repo = ScheduleRepository(db)
        for tc in tcs:
            if tc.function.name != "create_schedule_items":
                messages.append(
                    {
                        "role": "tool",
                        "tool_call_id": tc.id,
                        "content": json.dumps({"ok": False, "error": "unknown tool"}),
                    }
                )
                continue
            try:
                args = json.loads(tc.function.arguments or "{}")
            except json.JSONDecodeError:
                args = {}
            created = await repo.create_from_tool_items(user_id, args.get("items") or [])
            created_all.extend(created)
            messages.append(
                {
                    "role": "tool",
                    "tool_call_id": tc.id,
                    "content": json.dumps(
                        {"ok": True, "created_count": len(created)}, ensure_ascii=False
                    ),
                }
            )

    llm_raw = pack_llm_raw_payload(
        {
            "provider": prov_label,
            "model": model,
            "rounds": raw_rounds,
            "note": "stopped: max tool rounds",
        }
    )
    return "（日程工具调用次数过多，请简化请求）", created_all, total_usage, llm_raw


async def run_chat_with_schedules(
    db: AsyncSession,
    user_id: str,
    message: str,
    spirit_type: str | None,
    is_group_chat: bool,
    client_now_iso: str | None,
) -> tuple[str, list[dict[str, Any]], dict[str, Any] | None, str | None]:
    provider, api_key, base_url = config.get_ai_client_config()
    if provider == "minimax":
        system = build_system_minimax(spirit_type, is_group_chat, client_now_iso)
        text, usage, raw_body = await _chat_minimax(api_key, base_url, system, message)
        clean, items = extract_minimax_schedule_block(text)
        created: list[dict[str, Any]] = []
        if items:
            repo = ScheduleRepository(db)
            created = await repo.create_from_tool_items(user_id, items)
        llm_raw = pack_llm_raw_payload({"provider": "minimax", "response_body": raw_body})
        return clean, created, usage, llm_raw

    model = "deepseek-chat" if provider == "deepseek" else "gpt-3.5-turbo"
    system = build_system_openai(spirit_type, is_group_chat, client_now_iso)
    return await chat_openai_with_schedule_tools(
        api_key, base_url, model, system, message, db, user_id
    )
