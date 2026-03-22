# Schedule App 后端

AI 智能日程管理后端，简易版，实现 AI 调用。后续可扩展：上下文压缩、RAG、用户偏好识别与长期存储。

> 📖 **运行指南**：详见 [docs/如何运行后端.md](docs/如何运行后端.md)

## 技术栈

- **FastAPI** - Web 框架
- **PostgreSQL + pgvector** - 关系数据与向量存储（RAG 用）
- **MiniMax / DeepSeek / OpenAI** - AI 接口（按 .env 配置优先级）
- **python-dotenv** - 环境变量

## 快速开始

### 1. 安装 uv（如未安装）

```bash
# Windows (PowerShell)
irm https://astral.sh/uv/install.ps1 | iex

# 或 pip / pipx
pip install uv
```

### 2. 配置数据库（PostgreSQL + pgvector）

本地已有 PostgreSQL 时：

1. **创建数据库**：`createdb schedule_app`（或 pgAdmin 中新建）
2. **安装 pgvector 扩展**（若未安装）：
   - Windows: 下载 [pgvector 发布包](https://github.com/pgvector/pgvector/releases) 或 `stackbuilder`
   - 在数据库中执行：`CREATE EXTENSION vector;`
3. **配置 .env**：`DATABASE_URL=postgresql+asyncpg://用户名:密码@localhost:5432/schedule_app`

若本地无 PostgreSQL，可用 Docker：`docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres pgvector/pgvector`

### 3. 安装依赖并启动

```bash
cd schedule_backend
uv sync                    # 创建虚拟环境并安装依赖
cp .env.example .env       # 编辑 .env，填入 MINIMAX_API_KEY、DATABASE_URL 等
uv run python run.py       # 启动服务（自动创建表并启用 pgvector）
```

### 4. 常用命令

```bash
uv sync                    # 安装/同步依赖
uv add <包名>              # 添加依赖
uv run python run.py       # 运行（自动使用项目虚拟环境）
uv run uvicorn app.main:app --reload --port 8000
```

- API 文档: http://localhost:8000/docs
- 健康检查: http://localhost:8000/health
- **用量监控后台**: http://localhost:8000/admin（Vue 3 构建，需先 `cd admin-ui && npm run build`）

### 5. 网络问题排查

若 `uv sync` 超时或连接失败：

- **切换镜像**：编辑 `pyproject.toml` 中 `[tool.uv] index-url`，可尝试阿里云/中科大
- **关闭代理**：`$env:HTTP_PROXY=''; $env:HTTPS_PROXY=''; uv sync`
- **改用 pip**：`python -m venv .venv` → 激活 venv → `pip install -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/`

### 6. Flutter 对接

在 `schedule_app_flutter/lib/services/api_service.dart` 中修改 `baseUrl`：

- 本地开发（模拟器）: `http://10.0.2.2:8000/api`（Android）或 `http://localhost:8000/api`
- 真机：使用电脑局域网 IP，如 `http://192.168.1.100:8000/api`

## 接口说明

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/ai/chat | AI 聊天 |

**请求体示例：**
```json
{
  "message": "帮我安排明天上午的学习计划",
  "spiritType": "light",
  "isGroupChat": false
}
```

**响应示例：**
```json
{
  "response": "好的，以下是明天上午的学习计划建议..."
}
```

## 数据库表结构

| 表 | 说明 |
|----|------|
| `users` | 用户（id, nickname） |
| `chat_messages` | 聊天记录，用于上下文压缩、多轮对话 |
| `user_preferences` | 用户偏好（含 embedding 向量列），用于 RAG 检索 |

**迁移（Alembic）**：启动时自动执行 `alembic upgrade head`。手动迁移：`uv run alembic upgrade head`

**种子数据**：`uv run python scripts/seed.py`（写入 3 个测试用户、5 条偏好、2 条聊天记录）

## 后续扩展方向

- **上下文压缩**：从 `chat_messages` 取历史，摘要后注入 prompt，节约 token
- **RAG**：用户偏好 embedding 存入 `user_preferences`，检索相似偏好注入 prompt
- **长期存储**：用户偏好、日程习惯持久化
