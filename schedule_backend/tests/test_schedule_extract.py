"""schedule_ai 日程 JSON 提取与配置单测（不调用外网）"""
import unittest
from unittest.mock import patch

from app.config import Config
from app.services.schedule_ai import (
    _provider_label_from_base_url,
    _try_loose_schedule_json,
    extract_minimax_schedule_block,
)


class TestLooseScheduleJson(unittest.TestCase):
    def test_loose_finds_items_object(self) -> None:
        text = (
            "好的，帮你安排。"
            '{"items":[{"title":"晨跑","description":"","'
            'start_iso":"2026-03-31T07:00:00+08:00","end_iso":"2026-03-31T08:00:00+08:00",'
            '"category":"soil","is_all_day":false,"repeat":"never"}]}'
        )
        items = _try_loose_schedule_json(text)
        self.assertIsNotNone(items)
        assert items is not None
        self.assertEqual(items[0].get("title"), "晨跑")

    def test_loose_returns_none_without_items(self) -> None:
        self.assertIsNone(_try_loose_schedule_json("今天天气不错"))

    def test_extract_without_marker_uses_loose(self) -> None:
        body = (
            '{"items":[{"title":"开会","description":"",'
            '"start_iso":"2026-04-01T14:00:00+08:00","end_iso":"2026-04-01T15:00:00+08:00",'
            '"category":"light","is_all_day":false,"repeat":"never"}]}'
        )
        clean, items = extract_minimax_schedule_block("回复正文\n" + body)
        self.assertIsNotNone(items)
        assert items is not None
        self.assertEqual(items[0].get("title"), "开会")
        self.assertIn("回复正文", clean)

    def test_extract_with_marker_prefers_block(self) -> None:
        raw = """好的
<<<SCHEDULE_TOOL
{"items":[{"title":"标记块","description":"","start_iso":"2026-04-01T09:00:00+08:00","end_iso":"2026-04-01T10:00:00+08:00","category":"water","is_all_day":false,"repeat":"never"}]}
>>>尾"""
        clean, items = extract_minimax_schedule_block(raw)
        self.assertIsNotNone(items)
        assert items is not None
        self.assertEqual(items[0].get("title"), "标记块")


class TestProviderLabelFromBaseUrl(unittest.TestCase):
    def test_labels(self) -> None:
        self.assertEqual(_provider_label_from_base_url("https://api.minimax.chat/v1"), "minimax")
        self.assertEqual(_provider_label_from_base_url("https://api.siliconflow.cn/v1"), "siliconflow")
        self.assertEqual(_provider_label_from_base_url("https://api.deepseek.com/v1"), "deepseek")
        self.assertEqual(_provider_label_from_base_url("https://api.openai.com/v1"), "openai")


class TestScheduleAiClientConfig(unittest.TestCase):
    @patch.object(Config, "OPENAI_API_KEY", "")
    @patch.object(Config, "DEEPSEEK_BASE_URL", "https://api.deepseek.com")
    @patch.object(Config, "DEEPSEEK_API_KEY", "dk-secret")
    @patch.object(Config, "MINIMAX_API_KEY", "mk-secret")
    def test_prefers_deepseek_over_minimax_for_schedule(self) -> None:
        p, key, _ = Config.get_schedule_ai_client_config()
        self.assertEqual(p, "deepseek")
        self.assertEqual(key, "dk-secret")
