# 光合日历（ScheduleApp）

移动端日程与 AI 陪伴应用：**Flutter 客户端** + **Python 后端 API**。

## 仓库结构

```
ScheduleApp/
├── schedule_app_flutter/   # Flutter 客户端
└── schedule_backend/       # FastAPI 后端（当前主分支版本）
```

## 快速开始

### 后端

```powershell
cd schedule_backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env   # 配置数据库与 API Key
# 按项目内 migrations / alembic 说明初始化数据库后：
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API 文档：启动后访问 `http://localhost:8000/docs`（以实际路由为准）。

### 客户端

```powershell
cd schedule_app_flutter
flutter pub get
flutter run
```

真机调试时，在客户端配置后端 Base URL（见 `schedule_app_flutter/lib/services/api_service.dart`）。

## 其他分支

| 分支 | 说明 |
|------|------|
| `archive/monorepo-2026-06-03` | 重组前的完整 monorepo 快照 |
| `legacy/admin-ui` | Vue 用量管理后台 |
| `legacy/backend-schedule-backend` | 早期 FastAPI 后端（uv/pyproject 版） |
| `legacy/product-web` | 产品 Web 原型 |
| `legacy/schedule-pc-agent` | 桌面端 Tauri 实验 |
| `backend` | 历史 Flutter-only 根目录布局 |

## 技术栈

- **客户端**：Flutter 3.x、Provider
- **后端**：FastAPI、SQLAlchemy、Alembic、Docker（可选）

## License

Private / 面试展示用 — 请勿将 `.env` 与密钥提交到 Git。
