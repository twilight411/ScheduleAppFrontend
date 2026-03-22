# Schedule App 用量监控后台

Vue 3 + Vite 构建，用于监控 Token 用量、用户排行、按日趋势。

- **按用户排行**：点击表格中某一用户行，进入该用户**每次请求**的明细（时间精确到秒、Token、模型、对话原文；若有 **`llm_response_json`** 则显示可折叠的**完整大模型响应 JSON**）。
- **对话原文**：默认每条用量记录都会带用户输入与 AI 回复（`USAGE_LOG_INCLUDE_CONVERSATION=true`）。生产可设为 `false` 只记 Token。改后需**重启后端**。

## 开发

**先启动后端**（另开一个终端）：

```bash
cd schedule_backend
uv run python run.py
```

再启动前端：

```bash
cd admin-ui
npm install
npm run dev
```

访问 http://localhost:5174/admin/ ，Vite 会代理 `/api` 到后端 8000 端口。

## 构建

```bash
npm run build
```

输出到 `../static/admin/`，由 FastAPI 在 `/admin` 提供。
