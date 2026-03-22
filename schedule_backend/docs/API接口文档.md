# Schedule App API 接口文档



cd d:\Users\zyx\Desktop\ScheduleApp\schedule_backend
uv run python scripts/test_api.py



> 默认后端地址：`http://localhost:8000`，请先启动后端：`uv run python run.py`

---

## 一、通用接口

### 1. 健康检查

```bash
curl http://localhost:8000/health
```

**PowerShell：**
```powershell
curl http://localhost:8000/health
```

**响应示例：**
```json
{"status": "ok"}
```

---

### 2. 根路径

```bash
curl http://localhost:8000/
```

**响应示例：**
```json
{"message": "Schedule App API", "docs": "/docs"}
```

---

## 二、AI 聊天

### POST /api/ai/chat

发送消息，获取 AI 回复。

**请求体：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| message | string | 是 | 用户消息内容 |
| spiritType | string | 否 | 精灵类型：light / water / soil / air / nutrition |
| isGroupChat | boolean | 否 | 是否群聊，默认 false |
| userId | string | 否 | 用户 ID，用于用量统计与日程归属 |
| clientNowIso | string | 否 | 客户端当前时间 ISO8601，**建议传**，便于 AI 解析「明天」「下午三点」并创建正确时间的日程 |

**创建日程**：当用户明确要求「帮我加日程/安排到日历」等时，AI 会调用工具写入数据库，并在响应里返回 `createdTasks`（与 Flutter `Task` JSON 一致）；App 会同步写入本地安排界面。MiniMax 通过文末 `<<<SCHEDULE_TOOL ... >>>` 结构化块实现；DeepSeek/OpenAI 使用标准 function calling。

**curl 命令：**

```bash
curl -X POST http://localhost:8000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"你好，帮我安排明天上午的学习计划\"}"
```

**带精灵类型：**
```bash
curl -X POST http://localhost:8000/api/ai/chat \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"帮我规划学习\",\"spiritType\":\"light\",\"isGroupChat\":false}"
```

**带用户 ID（用量统计）：**
```bash
curl -X POST http://localhost:8000/api/ai/chat \
  -H "Content-Type: application/json" \
  -H "X-User-Id: user_001" \
  -d "{\"message\":\"你好\"}"
```

**PowerShell（单行）：**
```powershell
curl.exe -X POST http://localhost:8000/api/ai/chat -H "Content-Type: application/json" -d "{\"message\":\"你好\"}"
```

**PowerShell（多行，可读性更好）：**
```powershell
$body = '{"message":"你好，帮我安排明天上午"}'
Invoke-RestMethod -Uri http://localhost:8000/api/ai/chat -Method POST -ContentType "application/json" -Body $body
```

**响应示例：**
```json
{
  "response": "已经帮你在明天 9:00–10:00 加了一条学习安排～",
  "createdTasks": [
    {
      "id": 1,
      "title": "数学复习",
      "description": "",
      "startDate": 1770886800000,
      "endDate": 1770890400000,
      "category": "light",
      "repeatOption": "never",
      "isAllDay": false
    }
  ]
}
```

---

### GET /api/schedules

拉取当前用户的日程列表（与上表 `createdTasks` 单项结构相同）。需传 `X-User-Id` 或查询参数 `userId`。

```bash
curl -H "X-User-Id: user_001" "http://localhost:8000/api/schedules?limit=100"
```

---

## 三、用量监控（Admin）

### GET /api/admin/usage/stats

用量汇总。

**参数：** `days`（可选，默认 7，范围 1–90）

```bash
curl "http://localhost:8000/api/admin/usage/stats?days=7"
```

**PowerShell：**
```powershell
curl "http://localhost:8000/api/admin/usage/stats?days=7"
```

**响应示例：**
```json
{
  "total_tokens": 1234,
  "prompt_tokens": 800,
  "completion_tokens": 434,
  "request_count": 5,
  "days": 7
}
```

---

### GET /api/admin/usage/by-user

按用户用量排行。

```bash
curl "http://localhost:8000/api/admin/usage/by-user?days=7"
```

**响应示例：**
```json
[
  {"user_id": "user_001", "total_tokens": 800, "request_count": 3},
  {"user_id": "anonymous", "total_tokens": 434, "request_count": 2}
]
```

---

### GET /api/admin/usage/daily

按日用量趋势。

```bash
curl "http://localhost:8000/api/admin/usage/daily?days=7"
```

**响应示例：**
```json
[
  {"date": "2025-02-12", "total_tokens": 500, "request_count": 2},
  {"date": "2025-02-13", "total_tokens": 734, "request_count": 3}
]
```

---

### GET /api/admin/usage/user/{user_id}/logs

单用户**每一次** AI 请求的明细（`created_at` 为 ISO8601，含日期与**时分秒**）。

**参数：**

| 参数 | 说明 |
|------|------|
| `days` | 查询最近多少天，默认 7，范围 1–90 |
| `limit` | 最多返回条数，默认 500，最大 2000 |

```bash
curl "http://localhost:8000/api/admin/usage/user/user_001/logs?days=7"
```

**响应示例：**
```json
{
  "user_id": "user_001",
  "days": 7,
  "logs": [
    {
      "id": 12,
      "created_at": "2026-02-12T08:30:45.123456+00:00",
      "provider": "minimax",
      "model": "MiniMax-Text-01",
      "prompt_tokens": 100,
      "completion_tokens": 50,
      "total_tokens": 150,
      "user_message": "你好",
      "assistant_message": "你好！有什么可以帮你？",
      "llm_response_json": "{\"provider\":\"minimax\",\"response_body\":{...}}"
    }
  ]
}
```

> **`llm_response_json`**：字符串，内容为 JSON（需 `json.loads`）。MiniMax 为 `{"provider":"minimax","response_body":<接口完整 JSON>}`；DeepSeek/OpenAI 为含 `rounds` 的多轮补全快照。由 **`USAGE_LOG_INCLUDE_LLM_RAW`** 控制（默认 `true`）；需迁移 **005**。管理台用户明细里可折叠查看格式化后的 JSON。

> **对话原文**：每次成功调用 `/api/ai/chat` 都会插入一条 `usage_logs`。环境变量 **`USAGE_LOG_INCLUDE_CONVERSATION`** 默认为 `true`，此时同一条记录会写入 `user_message`（用户本轮输入）与 `assistant_message`（AI 回复全文）。设为 `false` 则只记 Token、不存正文（适合生产）。
>
> 若大模型响应里**没有** `usage` 字段，仍会插入一条记录，Token 可能为 0，但对话正文照常按上条规则写入。

---

## 四、一键测试脚本

```bash
cd schedule_backend
uv run python scripts/test_api.py
```

会依次测试上述所有接口并打印结果。

---

## 五、在线文档

浏览器访问：http://localhost:8000/docs 可查看 Swagger 文档并在线调试。
