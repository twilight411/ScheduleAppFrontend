# 🌳 精灵日程管理系统 (Spirit Scheduler)

基于 AI 的智能日程管理系统，通过5个拟人化的"精灵"角色帮助用户管理不同领域的任务和时间安排。

## 五大精灵

| 精灵 | 领域 | 人格 |
|------|------|------|
| 💡 光精灵 | 工作、学习 | 严谨高效、目标导向 |
| 💧 水精灵 | 娱乐、休闲 | 活泼轻松、善于调节 |
| 🌱 土壤精灵 | 健康、运动 | 温和坚定、关爱健康 |
| 💨 空气精灵 | 社交、人际 | 热情善解、情商高 |
| ✨ 营养精灵 | 兴趣、成长 | 鼓励探索、激发灵感 |

## 技术栈

- **后端**: FastAPI + Python 3.12
- **数据库**: PostgreSQL 16 + Redis 7
- **ORM**: SQLAlchemy 2.0 (async)
- **迁移**: Alembic
- **任务队列**: Celery
- **鉴权**: JWT (PyJWT + bcrypt)

## 快速开始

```bash
# 1. 复制环境变量
cp .env.example .env
# 编辑 .env 设置 JWT_SECRET 和 LLM_API_KEY

# 2. 启动所有服务
docker-compose up -d

# 3. 初始化模板数据
docker-compose exec api python -m scripts.init_templates

# 4. 访问 API 文档
open http://localhost:8000/docs
```

## 项目结构

```
spirit-scheduler/
├── app/
│   ├── main.py              # FastAPI 入口
│   ├── config.py            # 配置管理
│   ├── database.py          # 数据库连接
│   ├── middleware/           # 中间件（鉴权、限流、错误处理）
│   ├── models/              # ORM 模型（20张表）
│   ├── schemas/             # Pydantic 请求/响应
│   ├── routers/             # API 路由
│   ├── services/            # 业务逻辑层
│   ├── ai/                  # AI 模块（解析、精灵、调度、协商）
│   ├── jobs/                # Celery 定时任务
│   └── utils/               # 工具函数
├── migrations/              # Alembic 迁移
├── tests/                   # 测试
├── scripts/                 # 初始化脚本
├── docker-compose.yml
└── Dockerfile
```

## 开发阶段

| Phase | 内容 | 状态 |
|-------|------|------|
| 0 | 基础设施（项目骨架、DB、中间件） | ✅ 完成 |
| 1 | 用户服务 + 画像 + 精灵强度 | 🔲 待开发 |
| 2 | 任务系统（解析、拆解、对话） | 🔲 待开发 |
| 3 | 日程调度 | 🔲 待开发 |
| 4 | 协商引擎 | 🔲 待开发 |
| 5 | 报告系统（周报、生命树、果实） | 🔲 待开发 |
| 6 | 通知 + 定时任务 | 🔲 待开发 |
| 7 | 优化上线 | 🔲 待开发 |
