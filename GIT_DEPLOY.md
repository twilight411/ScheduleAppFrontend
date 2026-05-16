# 后端 GitHub 版本管理与发布

## 分支约定

- `main`: 线上稳定分支（生产部署）
- `dev`: 日常开发分支

## 首次接入服务器（一次性）

1. 在服务器上执行：

```bash
REPO_URL=https://github.com/<owner>/<repo>.git \
BRANCH=main \
bash scripts/bootstrap_git_on_server.sh
```

2. 脚本会自动：
   - 备份当前 `/app/spirit-scheduler`
   - 克隆 Git 仓库
   - 保留 `.env`、`spirit.db`、`web_build`
   - 重启 `spirit-scheduler` 服务

## 日常发布

```bash
bash scripts/deploy_backend.sh main
```

如需发布测试分支：

```bash
bash scripts/deploy_backend.sh dev
```

## 注意事项

- `app/main.py` 中保留了 `web_build` 静态挂载，确保 `http://<server>:8000/` Flutter Web 入口稳定。
- `.env` 与数据库文件不入库，仍由服务器本地管理。
