"""
验证「OpenAI 兼容 API + function calling」路径下模型可调用 create_schedule_items 生成日程。

不访问外网：Mock OpenAI 客户端与 ScheduleRepository.create_from_tool_items。
"""
from __future__ import annotations

import json
import unittest
from types import SimpleNamespace
from unittest.mock import AsyncMock, MagicMock, patch

from app.repositories.schedule_repository import ScheduleRepository
from app.services.schedule_ai import chat_openai_with_schedule_tools, run_chat_with_schedules


def _resp_with_tool_calls(arguments: dict[str, object]) -> SimpleNamespace:
    tc = SimpleNamespace(
        id="call_tool_1",
        function=SimpleNamespace(
            name="create_schedule_items",
            arguments=json.dumps(arguments, ensure_ascii=False),
        ),
    )
    msg = SimpleNamespace(role="assistant", content=None, tool_calls=[tc])
    return SimpleNamespace(
        choices=[SimpleNamespace(message=msg)],
        usage=SimpleNamespace(prompt_tokens=100, completion_tokens=20, total_tokens=120),
        model="deepseek-chat",
    )


def _resp_text_only(content: str) -> SimpleNamespace:
    msg = SimpleNamespace(role="assistant", content=content, tool_calls=None)
    return SimpleNamespace(
        choices=[SimpleNamespace(message=msg)],
        usage=SimpleNamespace(prompt_tokens=10, completion_tokens=30, total_tokens=40),
        model="deepseek-chat",
    )


class TestChatOpenAiScheduleTools(unittest.IsolatedAsyncioTestCase):
    async def test_model_tool_call_invokes_repo_and_returns_created_tasks(self) -> None:
        """第一轮返回 tool_calls，第二轮返回自然语言；仓储应写入并出现在返回值中。"""
        items_arg = {
            "items": [
                {
                    "title": "模型工具测试日程",
                    "description": "",
                    "start_iso": "2026-04-15T14:00:00+08:00",
                    "end_iso": "2026-04-15T15:00:00+08:00",
                    "category": "light",
                    "is_all_day": False,
                    "repeat": "never",
                }
            ]
        }
        fake_created = [
            {
                "id": 42,
                "title": "模型工具测试日程",
                "description": "",
                "startDate": 1,
                "endDate": 2,
                "category": "light",
                "repeatOption": "never",
                "isAllDay": False,
            }
        ]

        mock_client = MagicMock()
        mock_client.chat.completions.create.side_effect = [
            _resp_with_tool_calls(items_arg),
            _resp_text_only("好的，已把「模型工具测试日程」记进日历。"),
        ]
        mock_openai_cls = MagicMock(return_value=mock_client)

        db = MagicMock()

        with patch("app.services.schedule_ai.OpenAI", mock_openai_cls):
            with patch.object(
                ScheduleRepository,
                "create_from_tool_items",
                new_callable=AsyncMock,
                return_value=fake_created,
            ) as mock_create:
                text, created_all, usage, raw = await chat_openai_with_schedule_tools(
                    "fake-key",
                    "https://api.deepseek.com",
                    "deepseek-chat",
                    "system prompt",
                    "明天下午两点安排开会",
                    db,
                    "user-tool-test",
                )

        self.assertEqual(len(created_all), 1)
        self.assertEqual(created_all[0]["title"], "模型工具测试日程")
        self.assertIn("记进日历", text)
        mock_create.assert_awaited_once()
        cargs, _ = mock_create.call_args
        self.assertEqual(cargs[0], "user-tool-test")
        self.assertEqual(len(cargs[1]), 1)
        self.assertEqual(cargs[1][0]["title"], "模型工具测试日程")

        self.assertIsNotNone(usage)
        assert usage is not None
        self.assertEqual(usage.get("provider"), "deepseek")
        self.assertIsNotNone(raw)

        # 应发起两轮 completions（工具轮 + 回复轮）
        self.assertEqual(mock_client.chat.completions.create.call_count, 2)

    async def test_empty_second_reply_uses_fallback_when_tasks_created(self) -> None:
        """第二轮若 content 为空，应使用兜底文案（仍视为工具链路成功）。"""
        items_arg = {
            "items": [
                {
                    "title": "仅兜底文案",
                    "description": "",
                    "start_iso": "2026-05-01T09:00:00+08:00",
                    "end_iso": "2026-05-01T10:00:00+08:00",
                    "category": "water",
                    "is_all_day": False,
                    "repeat": "never",
                }
            ]
        }
        fake_created = [
            {
                "id": 7,
                "title": "仅兜底文案",
                "description": "",
                "startDate": 1,
                "endDate": 2,
                "category": "water",
                "repeatOption": "never",
                "isAllDay": False,
            }
        ]

        mock_client = MagicMock()
        mock_client.chat.completions.create.side_effect = [
            _resp_with_tool_calls(items_arg),
            _resp_text_only(""),
        ]
        mock_openai_cls = MagicMock(return_value=mock_client)

        with patch("app.services.schedule_ai.OpenAI", mock_openai_cls):
            with patch.object(
                ScheduleRepository,
                "create_from_tool_items",
                new_callable=AsyncMock,
                return_value=fake_created,
            ):
                text, created_all, _, _ = await chat_openai_with_schedule_tools(
                    "k",
                    "https://api.deepseek.com",
                    "deepseek-chat",
                    "sys",
                    "加一条日程",
                    MagicMock(),
                    "u2",
                )

        self.assertTrue(created_all)
        self.assertIn("已经为你记好", text)


class TestRunChatWithSchedulesToolPath(unittest.IsolatedAsyncioTestCase):
    async def test_deepseek_routes_to_chat_openai_with_schedule_tools(self) -> None:
        """run_chat_with_schedules 在 deepseek 配置下应委托 chat_openai_with_schedule_tools（不请求网络）。"""
        from app.config import Config

        with patch.object(
            Config,
            "get_schedule_ai_client_config",
            return_value=("deepseek", "k", "https://api.deepseek.com"),
        ):
            with patch(
                "app.services.schedule_ai.chat_openai_with_schedule_tools",
                new_callable=AsyncMock,
            ) as mock_chat:
                mock_chat.return_value = ("好的", [{"id": 1, "title": "t"}], None, None)
                await run_chat_with_schedules(
                    MagicMock(),
                    "user-x",
                    "帮我明天下午加一条日程",
                    None,
                    True,
                    "2026-04-01T12:00:00+08:00",
                )

        mock_chat.assert_awaited_once()
        cargs = mock_chat.call_args[0]
        self.assertEqual(cargs[0], "k")
        self.assertEqual(cargs[1], "https://api.deepseek.com")
        self.assertEqual(cargs[2], "deepseek-chat")
        self.assertEqual(cargs[4], "帮我明天下午加一条日程")
        self.assertEqual(cargs[6], "user-x")


class TestRunChatWithSchedulesSiliconFlow(unittest.IsolatedAsyncioTestCase):
    async def test_siliconflow_uses_config_model(self) -> None:
        """日程在仅配置硅基流动时应走 chat_openai_with_schedule_tools + SILICONFLOW_CHAT_MODEL。"""
        from app.config import Config

        with patch.object(
            Config,
            "get_schedule_ai_client_config",
            return_value=("siliconflow", "k", "https://api.siliconflow.cn/v1"),
        ):
            with patch.object(Config, "SILICONFLOW_CHAT_MODEL", "Qwen/Qwen2.5-7B-Instruct"):
                with patch(
                    "app.services.schedule_ai.chat_openai_with_schedule_tools",
                    new_callable=AsyncMock,
                ) as mock_chat:
                    mock_chat.return_value = ("ok", [], None, None)
                    await run_chat_with_schedules(
                        MagicMock(),
                        "u",
                        "加日程",
                        None,
                        True,
                        None,
                    )

        cargs = mock_chat.call_args[0]
        self.assertEqual(cargs[2], "Qwen/Qwen2.5-7B-Instruct")


class TestRunChatWithSchedulesMinimaxOpenAITools(unittest.IsolatedAsyncioTestCase):
    async def test_minimax_routes_to_openai_compatible_tools_with_chat_model(self) -> None:
        """仅配置 MiniMax 时，日程应走 api.minimax.chat/v1 + MINIMAX_CHAT_MODEL + tools。"""
        from app.config import Config

        with patch.object(
            Config,
            "get_schedule_ai_client_config",
            return_value=("minimax", "k", "https://api.minimax.chat/v1"),
        ):
            with patch.object(Config, "MINIMAX_SCHEDULE_USE_OPENAI_TOOLS", True):
                with patch.object(Config, "MINIMAX_CHAT_MODEL", "MiniMax-M2.5"):
                    with patch(
                        "app.services.schedule_ai.chat_openai_with_schedule_tools",
                        new_callable=AsyncMock,
                    ) as mock_chat:
                        mock_chat.return_value = ("ok", [], None, None)
                        await run_chat_with_schedules(
                            MagicMock(),
                            "u",
                            "明天下午提醒我跑步",
                            None,
                            True,
                            None,
                        )

        mock_chat.assert_awaited_once()
        cargs = mock_chat.call_args[0]
        self.assertEqual(cargs[0], "k")
        self.assertEqual(cargs[1], "https://api.minimax.chat/v1")
        self.assertEqual(cargs[2], "MiniMax-M2.5")
        self.assertEqual(cargs[4], "明天下午提醒我跑步")
        self.assertEqual(cargs[6], "u")
