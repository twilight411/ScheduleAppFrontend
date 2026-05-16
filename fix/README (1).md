# P1 修复说明 — 应用指引

本目录包含 3 个 P1 问题的修复（P1-3 的 24h 过期任务在你代码里**已经实现**，
只是当时 audit 时看漏了——`overdue_check.py` 里有 `expire_suggestions`，已注册到 03:00）。

---

## 实际解决的 3 个 P1 问题

| # | 问题 | 解决方案 |
|---|---|---|
| **P1-1** | SQLite 写锁导致数据库死锁 | 切换 PostgreSQL（DB 无关 GUID + Docker + Alembic 引导） |
| **P1-2** | 群聊不是真对话，精灵互不响应 | `free_chat.py` 重写为 4 阶段头脑风暴状态机 |
| **P1-4** | 路由层重复 commit | 删除 `notifications/reports/tree.py` 里 7 处 `db.commit()` |

---

## 文件清单 → 目标路径

| 输出文件 | 目标路径 | 改动类型 |
|---|---|---|
| `app/models/_types.py` | `app/models/_types.py` | **新增** |
| `app/database.py` | `app/database.py` | **覆盖** |
| `app/config.py` | `app/config.py` | **覆盖** |
| `app/ai/free_chat.py` | `app/ai/free_chat.py` | **覆盖**（语义重构） |
| `app/routers/notifications.py` | `app/routers/notifications.py` | **覆盖** |
| `app/routers/reports.py` | `app/routers/reports.py` | **覆盖** |
| `app/routers/tree.py` | `app/routers/tree.py` | **覆盖** |
| `scripts/migrate_uuid_to_guid.py` | `scripts/migrate_uuid_to_guid.py` | **新增** |
| `deploy/docker-compose.yml` | `deploy/docker-compose.yml` | **新增** |
| `deploy/Dockerfile` | `deploy/Dockerfile` | **新增** |
| `deploy/.env.example` | `.env.example`（项目根） | **新增** |
| `migrations/SETUP.md` | 阅读用 | 操作手册 |

---

## P1-1 切到 PostgreSQL — 执行步骤

### Step 1：放置新文件
```bash
# 把 _types.py 放到 models 目录
cp p1_fixes/app/models/_types.py 你的项目/app/models/

# 覆盖 database.py 和 config.py
cp p1_fixes/app/database.py 你的项目/app/
cp p1_fixes/app/config.py 你的项目/app/

# 放置迁移脚本
mkdir -p 你的项目/scripts
cp p1_fixes/scripts/migrate_uuid_to_guid.py 你的项目/scripts/
```

### Step 2：批量替换 model 里的 PG UUID

```bash
cd 你的项目

# 干跑预览
python scripts/migrate_uuid_to_guid.py

# 实际写入
python scripts/migrate_uuid_to_guid.py --apply
```

涉及 9 个 model 文件，会批量把：
```python
from sqlalchemy.dialects.postgresql import UUID
UUID(as_uuid=True)
```
替换为：
```python
from app.models._types import GUID
GUID
```

> ⚠ 测过实际项目文件没问题，但建议替换后 `git diff` 走查一遍确认。

### Step 3：放置部署文件

```bash
cp p1_fixes/deploy/docker-compose.yml 你的项目/deploy/
cp p1_fixes/deploy/Dockerfile 你的项目/deploy/
cp p1_fixes/deploy/.env.example 你的项目/.env.example

# 复制并改密钥
cp 你的项目/.env.example 你的项目/.env
# 把 JWT_SECRET、POSTGRES_PASSWORD、LLM_API_KEY 改成真实值
```

### Step 4：requirements.txt 加依赖

```
asyncpg>=0.29
psycopg2-binary>=2.9        # Alembic 同步 driver 用
alembic>=1.13
email-validator>=2.0        # P0 已经需要
```

### Step 5：起 PostgreSQL，跑迁移

**方式 A：用 Docker 起 PG（推荐）**
```bash
cd 你的项目
docker compose -f deploy/docker-compose.yml up -d db redis
# 等 healthcheck 通过
docker compose -f deploy/docker-compose.yml ps
```

**方式 B：本地装 PG**
```bash
# Mac: brew install postgresql@16
# Linux: apt install postgresql-16
createdb spirit
```

然后跑表创建：
```bash
# 临时方式（开发）：用 init_db
python -c "import asyncio; from app.database import init_db; asyncio.run(init_db())"

# 正式方式：用 Alembic（看 migrations/SETUP.md）
alembic upgrade head
```

### Step 6：跑应用

```bash
# 把 .env 里的 DATABASE_URL 改为 PG
# DATABASE_URL=postgresql+asyncpg://spirit:你的密码@localhost:5432/spirit

uvicorn app.main:app --reload
curl http://localhost:8000/api/v1/health/ready
# 期望：{"status":"ready","checks":{"database":true,"redis":true}}
```

### 怎么验证死锁解决了？

切到 PG 后，重跑 P0 文档里的死锁测试：

```bash
# 同时开 5 个终端 hit /ai/negotiate，再开第 6 个 hit /tasks
# 期望：所有请求正常返回，没有 "database is locked" 或 timeout
```

---

## P1-2 群聊重构 — 新 API 行为

### 状态机（4 个阶段）

```
[Init] 选定 2-3 个精灵 + 生成话题
   ↓
[Phase 1: PROPOSALS]  每个精灵独立提议（事项+时间+理由）
   → SSE: spirit_message (type=proposal) × N
   ↓
[Phase 2: DISCUSSION] 每个精灵对其他精灵的提议表态
   → SSE: spirit_message (type=discussion, stance=support/oppose/blend) × M
   ↓
[Phase 3: SYNTHESIS]  主持人综合所有意见 → ONE 任务
   → SSE: orchestrator (type=synthesis)
   ↓
[Phase 4: CONSENSUS_CHECK] 各精灵对最终方案的最终表态
   → SSE: spirit_message (type=consensus_vote, accept=bool) × N
   ↓
[结尾]
   全员 accept → SSE: task_suggestion（前端弹窗确认）
   有人反对 → SSE: need_user_input（让用户做最终决定）
   ↓
[Done] SSE: done
```

### 关键差异（vs 旧版）

| | 旧版 | 新版 |
|---|---|---|
| 精灵互动 | 各精灵独立生成，互不响应 | 显式 stance：support / oppose / blend |
| 任务输出 | 每个精灵零散吐 task_suggestion | orchestrator 综合后输出唯一一个 |
| 共识机制 | 无 | 最后让所有精灵投票 |
| 反对处理 | 无 | 触发 need_user_input |

### 前端 SSE 处理示例

```js
const ev = new EventSource('/api/v1/ai/free-chat?topic=本周末怎么安排');

ev.addEventListener('topic_suggestion', e => {
  const data = JSON.parse(e.data);
  // 显示参与精灵 + 话题
});

ev.addEventListener('spirit_message', e => {
  const data = JSON.parse(e.data);
  // type ∈ {proposal, discussion, consensus_vote}
  // phase ∈ {proposals, discussion, consensus_check}
  renderBubble(data);
});

ev.addEventListener('orchestrator', e => {
  // 主持人综合发言
});

ev.addEventListener('task_suggestion', e => {
  // 共识达成 → 弹"添加到任务"确认框
  const task = JSON.parse(e.data);
});

ev.addEventListener('need_user_input', e => {
  // 有反对 → 弹用户决定的对话框
});

ev.addEventListener('done', () => ev.close());
```

### 为什么这样设计

1. **真对话**：Phase 2 的 discussion 用 stance 强制每个精灵对别人的提议表态，prompt 显式要求"不要和稀泥"
2. **可控收敛**：Phase 3 的 orchestrator 必须输出 ONE final_task，避免发散
3. **共识检查**：Phase 4 让精灵对最终方案投票，体现"群体决策"语义
4. **用户兜底**：有反对时不强行输出，让用户决定

---

## P1-4 删除重复 commit — 直接覆盖

3 个文件全量覆盖即可：
- `routers/notifications.py`（删 4 处 commit）
- `routers/reports.py`（删 2 处 commit）
- `routers/tree.py`（删 1 处 commit）

`get_db()` 在请求结束统一 commit，路由层不需要也不应该再 commit。

---

## 完整测试清单（P0 + P1 全部修复后）

### 注册（P0-1）
- [ ] 大写邮箱注册成功，DB 存为小写
- [ ] 同邮箱重复注册返回 409
- [ ] 非法邮箱格式返回 422
- [ ] 中文密码注册成功
- [ ] 注册后 GET /profile 返回完整 preferences（不为空）

### 死锁（P0-2 + P1-1）
- [ ] 5 个并发 /ai/negotiate + 1 个 /tasks → 全部成功
- [ ] PG 模式下 /health/ready 返回 ready

### chat-to-task（P0-3）
- [ ] "下周二去打球"（今天周二）→ date = 7 天后
- [ ] "明天去图书馆"（无强意图词）→ 仍能识别
- [ ] 多轮："明天有空吗" + "想下午爬山" → 识别

### 群聊触发器（P0-4）
- [ ] 创建任务后响应含 `should_negotiate` + `negotiation_suggestion`

### 群聊重构（P1-2）
- [ ] /ai/free-chat 流式输出按 4 阶段顺序：proposal → discussion → synthesis → vote
- [ ] 最终输出 task_suggestion（不是多次零散）
- [ ] discussion 阶段有 stance ∈ {support, oppose, blend}
- [ ] 全员同意 → task_suggestion；有反对 → need_user_input

### Commit 重复（P1-4）
- [ ] /notifications/* 路由不报"transaction in progress"
- [ ] /reports/* 同上
- [ ] /tree/* 同上

---

## 还没做的（P2，按 V3 规划）

| 任务 | 优先级 | 说明 |
|---|---|---|
| Alembic 接入主流程 | P2 | 现有 SETUP.md 是引导，需要按它实操 |
| LLM 调用限流 + 成本追踪 | P2 | `cost_tracker.py` 已存在但没有限流逻辑 |
| 文件上传 → 对象存储 | P2 | 现在还是本地磁盘 |
| Rate limit 接 Redis | P2 | 中间件结构在，缺接线（main.py 注释里有伪代码） |
| 灰度发布 / 监控告警 | P2 | 上线前最后一步 |

如果还要继续，下一步建议做 **Alembic 接入**（生产必备）和 **rate limit 接 Redis**（防刷）。
