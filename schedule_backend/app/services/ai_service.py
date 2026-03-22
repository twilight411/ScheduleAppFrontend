"""AI 聊天服务 - 支持 MiniMax / DeepSeek / OpenAI"""
from typing import Any

import httpx
from openai import OpenAI

from app.config import config

# 精灵类型对应的系统提示（后续可扩展为 RAG/用户偏好）
SPIRIT_SYSTEM_PROMPTS = {
    "light": "你是光精灵，专注工作与学习规划，帮助用户高效安排任务。",
    "water": "你是水精灵，专注娱乐与休闲，帮助用户放松和享受生活。",
    "soil": "你是土壤精灵，专注健康管理，帮助用户养成健康习惯。",
    "air": "你是空气精灵，专注社交与人际关系，帮助用户维护社交。",
    "nutrition": "你是营养精灵，专注爱好与兴趣，帮助用户发展个人爱好。",
}

DEFAULT_SYSTEM_PROMPT = """你是智能日程助手，帮助用户管理日程、安排任务、提供建议。
回复简洁友好，适合移动端阅读。"""

# 与 Flutter `lib/services/spirit_prompts.dart` 中群聊文案保持一致（远程对话走后端，必须在这里定义）
GROUP_CHAT_SYSTEM_PROMPT = """
你是五个小精灵的集合体，包括：
1. 小太阳（学习）- 温柔傲娇
2. 泡泡（娱乐）- 活泼俏皮
3. 培培（健康）- 温柔关怀
4. 悠悠（社交）- 优雅从容
5. 星星（兴趣）- 高冷傲娇

请从多个角度给出综合建议，帮助用户平衡生活的各个方面。
""".strip()


def get_system_prompt(spirit_type: str | None, is_group_chat: bool) -> str:
    """根据精灵类型和聊天模式生成系统提示"""
    if is_group_chat:
        # 群聊：用「五精灵综合」人设；勿再用泛化的「智能日程助手」以免与产品预期不符
        return GROUP_CHAT_SYSTEM_PROMPT
    if spirit_type and spirit_type in SPIRIT_SYSTEM_PROMPTS:
        return SPIRIT_SYSTEM_PROMPTS[spirit_type]
    return DEFAULT_SYSTEM_PROMPT


async def _chat_minimax(
    api_key: str, base_url: str, system_prompt: str, message: str
) -> tuple[str, dict[str, Any] | None, dict[str, Any]]:
    """调用 MiniMax API，返回 (content, usage, 完整 response JSON 对象，用于管理台调试)"""
    url = f"{base_url.rstrip('/')}/v1/text/chatcompletion_v2"
    payload = {
        "model": "M2-her",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": message},
        ],
    }
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    async with httpx.AsyncClient(timeout=60.0) as client:
        resp = await client.post(url, json=payload, headers=headers)
        if resp.status_code != 200:
            err = resp.json() if resp.content else {}
            msg = err.get("base_resp", {}).get("status_msg") or err.get("error", {}).get("message") or resp.text
            raise ValueError(f"MiniMax API 错误: {resp.status_code} - {msg}")
        data = resp.json()
    choices = data.get("choices", [])
    if not choices:
        raise ValueError(data.get("base_resp", {}).get("status_msg", "MiniMax 返回空回复"))
    content = choices[0].get("message", {}).get("content", "")
    usage = data.get("usage")
    usage_dict = None
    if usage:
        usage_dict = {
            "provider": "minimax",
            "model": data.get("model", "M2-her"),
            "prompt_tokens": usage.get("prompt_tokens", 0) or usage.get("input_tokens", 0),
            "completion_tokens": usage.get("completion_tokens", 0) or usage.get("output_tokens", 0),
            "total_tokens": usage.get("total_tokens", 0),
        }
    return content or "", usage_dict, data


async def _chat_openai_compatible(
    api_key: str, base_url: str, model: str, system_prompt: str, message: str
) -> tuple[str, dict[str, Any] | None]:
    """调用 OpenAI 兼容接口（DeepSeek / OpenAI），返回 (content, usage)"""
    client = OpenAI(api_key=api_key, base_url=base_url)
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": message},
        ],
    )
    content = (response.choices[0].message.content or "").strip()
    usage = None
    if response.usage:
        provider = "deepseek" if "deepseek" in base_url.lower() else "openai"
        usage = {
            "provider": provider,
            "model": response.model or model,
            "prompt_tokens": response.usage.prompt_tokens or 0,
            "completion_tokens": response.usage.completion_tokens or 0,
            "total_tokens": response.usage.total_tokens or 0,
        }
    return content, usage


async def chat(
    message: str, spirit_type: str | None = None, is_group_chat: bool = False
) -> tuple[str, dict[str, Any] | None, dict[str, Any] | None]:
    """
    调用 AI 接口获取回复
    返回 (content, usage_dict, raw_body)；OpenAI 兼容路径暂无整包 JSON，raw_body 为 None
    """
    provider, api_key, base_url = config.get_ai_client_config()
    system_prompt = get_system_prompt(spirit_type, is_group_chat)

    if provider == "minimax":
        c, u, raw = await _chat_minimax(api_key, base_url, system_prompt, message)
        return c, u, raw
    if provider == "deepseek":
        c, u = await _chat_openai_compatible(api_key, base_url, "deepseek-chat", system_prompt, message)
        return c, u, None
    c, u = await _chat_openai_compatible(api_key, base_url, "gpt-3.5-turbo", system_prompt, message)
    return c, u, None
