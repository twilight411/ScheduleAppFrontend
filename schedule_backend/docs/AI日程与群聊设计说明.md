# AI 日程与群聊 — 当前设计说明

## 整体架构

- **Flutter**：聊天 UI、`ChatProvider` 维护本地消息列表；发消息时调用 `RemoteAIChatRepository` → `POST /api/ai/chat`。
- **后端**：`app/routers/ai.py` 收 `message`、`spiritType`、`isGroupChat`、`userId`；`app/services/ai_service.py` 根据模式选 **一条** system prompt，再调 **一次** MiniMax / DeepSeek / OpenAI。
- **无多轮上下文**：每次请求只带 **system + 当前这一条 user**，**不会**把历史消息或 `chat_messages` 表里的记录拼进模型（后续若要「记得上文」需单独做上下文/RAG）。

## 群聊 vs 私聊（参数）

| 模式 | `isGroupChat` | `spiritType` | 后端 system 行为 |
|------|---------------|--------------|------------------|
| 群聊 | `true` | `null`（前端不传） | 使用「五精灵集合体」群聊提示（与 Flutter `SpiritPrompts._getGroupChatPrompt` 对齐） |
| 私聊 | `false` | `light` / `water` 等 | 使用对应精灵的短提示（`SPIRIT_SYSTEM_PROMPTS`） |

默认进入聊天常为 **群聊**（`ChatProvider.isGroupChat = true`）。

## 为什么群聊容易「诡异」或不像预期？

1. **不是真群聊**：只有一个模型、一次回复。提示里写「五位精灵」是让模型 **扮演综合顾问**，并不会真的跑 5 个独立 Agent；有时会出现人设混用、语气跳变或过度啰嗦。
2. **没有上下文**：用户说「刚才那个安排呢？」模型看不到「刚才」，容易答非所问或瞎编。
3. **私聊在长提示与短提示间不一致**：Flutter 本地 `SpiritPrompts` 里私聊是**很长**的人设；后端目前仍是**一行**精灵职责说明。若只用远程 API，私聊风格也会和本地 Mock 不一致（群聊提示已与 Flutter 群聊文案对齐）。
4. **接口/模型问题**：超时、空 `choices`、内容审核等会导致失败或空回复，与「群聊」逻辑无关，需看后端日志与 API 返回。

## AI 创建日程（工具）

- 用户说「帮我明天上午 9 点加一条学习安排」等时，后端会 **写库**（表 `schedule_tasks`）并在 `POST /api/ai/chat` 响应里返回 `createdTasks`；Flutter 将其转成 `Task` 写入本地日历。
- **DeepSeek / OpenAI**：标准 `create_schedule_items` 函数工具，可多轮 tool 调用。
- **MiniMax**：在 system 中要求模型在回复后输出 `<<<SCHEDULE_TOOL {"items":[...]} >>>` 块，服务端解析后落库并从展示文本中去掉该块。
- 请求体建议带 **`clientNowIso`**（设备当前时间 ISO8601），便于解析「明天」「下午」。

## 后续可改进方向（未实现）

- 将历史 N 条消息拼进 `messages` 做多轮对话。
- 私聊：把 Flutter 中长版精灵 prompt 同步到后端或改为配置下发。
- 真·多角色：多轮 function calling / 多段 assistant 消息模拟多精灵（成本高、需产品设计）。
- App 启动时 `GET /api/schedules` 与本地任务合并同步（当前仅依赖聊天响应里的 `createdTasks`）。
