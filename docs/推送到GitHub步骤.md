# 将本地 Monorepo 推到 twilight411/ScheduleAppFrontend

以下假设：本地 `ScheduleApp` 目录已包含 `schedule_app_flutter`、`schedule_backend`、`admin-ui`，且根目录已有 `README.md` 与 `.gitignore`。

## 若 `schedule_app_flutter` 里曾经单独 `git init` 过

外层 monorepo 会把该目录当成 **submodule（嵌套仓库）**，`git push` 后别人克隆下来 Flutter 目录是空的。处理方式：

1. **删除** `schedule_app_flutter/.git` 目录（只删这一层，不要删外层 `.git`）。
2. 在外层仓库执行：  
   `git rm --cached -f schedule_app_flutter`  
   再：  
   `git add schedule_app_flutter/`

（本地若已按本文档由助手初始化并提交，通常已处理完毕。）

---

## 情况 A：本地还没有 Git

在 **`ScheduleApp` 根目录**（与三个子文件夹同级）执行：

```powershell
cd D:\Users\zyx\Desktop\ScheduleApp
git init
git add .
git status
```

确认 **没有** `.env`、`node_modules`、`.venv` 等被加入后：

```powershell
git commit -m "chore: monorepo — Flutter + backend + admin-ui"
git branch -M main
git remote add origin https://github.com/twilight411/ScheduleAppFrontend.git
```

推送前请设置你的提交身份（若尚未全局配置）：

```powershell
git config user.name "你的名字"
git config user.email "你的邮箱"
```

（以上为本地仓库配置；也可用 `git config --global ...` 全局设置。）

继续推送（远程为空或与本地历史兼容时）：

```powershell
git push -u origin main
```

若远程 **已有提交且结构是「Flutter 在根」**，需要先决定：

- **用本地结构覆盖远程（慎用，会改写远程历史）**  
  `git push -u origin main --force`  
  仅在你确认远程可以丢弃或已备份时执行。

- **保留远程历史**  
  先 `git fetch origin`，再 `git merge origin/main --allow-unrelated-histories`，解决冲突后把旧根目录文件移入 `schedule_app_flutter/`，再提交推送。

## 情况 B：本地已是 Git 仓库

只需确保 `origin` 指向上述 GitHub 地址，在根目录 `git add` / `commit` / `push` 即可。

## 推送后建议

1. 在 GitHub **Settings → Repository name** 将仓库改名为 `ScheduleApp`（或 `GuangHeCalendar`），避免名称只剩 Frontend。
2. 更新本地 `git remote` 若 GitHub 提示新 URL。
3. 在仓库主页 **About** 里写一句简介：含 Flutter / FastAPI / Vue 管理台。
