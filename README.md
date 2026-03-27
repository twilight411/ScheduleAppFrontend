# 光合日历 · 全栈 Monorepo

本目录为**单体仓库**结构，包含移动端（Flutter）、后端（FastAPI）与用量管理后台（Vue）。

远程仓库：[twilight411/ScheduleAppFrontend](https://github.com/twilight411/ScheduleAppFrontend)（建议后续在 GitHub 将仓库重命名为 `ScheduleApp` 等更贴切的名字）

## 目录结构

```
ScheduleApp/
├── schedule_app_flutter/   # Flutter 客户端（光合日历 App）
├── init_ui_sandbox/        # 独立沙盒：仅调初始化/引导 UI，满意后再迁回主 Flutter 工程
├── schedule_backend/       # FastAPI + PostgreSQL + AI 接口
└── admin-ui/               # Vue 3 用量监控，构建产物输出到后端的 static/admin
```

## 快速启动（开发）

### 1. 后端

```powershell
cd schedule_backend
uv sync
cp .env.example .env   # 编辑填入数据库与 AI Key
uv run alembic upgrade head
uv run python run.py
```

默认 API：<http://localhost:8000>，文档：<http://localhost:8000/docs>

### 2. 管理台（可选）

```powershell
cd admin-ui
npm install
npm run dev
```

开发时访问说明见 `admin-ui/README.md`（Vite 代理 `/api`）。

### 3. Flutter（主 App）

```powershell
cd schedule_app_flutter
flutter pub get
flutter run
```

### 3b. Flutter 初始化界面沙盒（可选）

```powershell
cd init_ui_sandbox
flutter pub get
flutter run
```

说明见 `init_ui_sandbox/README.md`（与主工程解耦，调完再迁移 UI）。

真机连本机后端时，在代码中配置 `ApiService.overrideBaseUrl`（见 `schedule_backend/docs/移动端对接指南.md`）。

## 文档索引

| 说明 | 路径 |
|------|------|
| 后端运行与数据库 | `schedule_backend/docs/如何运行后端.md` |
| HTTP API | `schedule_backend/docs/API接口文档.md` |
| 移动端对接 | `schedule_backend/docs/移动端对接指南.md` |
| AI / 群聊 / 日程工具 | `schedule_backend/docs/AI日程与群聊设计说明.md` |

## 推送到 GitHub 的说明

- **不要提交**：各目录下的 `.env`、`node_modules/`、`.venv/`、`build/` 等（见根目录 `.gitignore`）。
- 若远程仓库**当前根目录就是 Flutter 工程**（`lib/`、`pubspec.yaml` 在根），与本地「`schedule_app_flutter/` 子目录」不一致时，有两种做法：
  1. **推荐**：在远程新建空默认分支或备份后，将本地本仓库作为新结构一次性推送（或 PR 把原根文件移入 `schedule_app_flutter/`）。
  2. 或：本地把 `schedule_app_flutter` 里的内容暂时拷到临时目录，克隆远程，在克隆根下创建 `schedule_app_flutter` 文件夹并拷入，再复制进 `schedule_backend`、`admin-ui`，提交推送。

更细的命令与「远程已有 Flutter 根目录」时的合并方式见：[docs/推送到GitHub步骤.md](./docs/推送到GitHub步骤.md)。

## 分支建议

- 使用 **`main`** 作为唯一主分支存放上述三目录；功能开发用 `feat/xxx` 等分支，**不要用单独分支长期只存后端或只存管理台**。
