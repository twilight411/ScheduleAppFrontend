# 光合日历 · 光网（ProductWeb）

独立静态站点：参考 [Lifelight](https://www.lifelight.me/) 的信息架构（价值陈述、回声墙、指南卡片、FAQ），视觉与素材与 `SchedulePCagent` 保持一致；设计过程对齐 [Impeccable](https://github.com/pbakaus/impeccable)。

## 开发

```bash
cd ProductWeb
npm install
npm run dev
```

## 构建

```bash
npm run build
```

产物在 `dist/`。图片通过 Vite 别名 `@schedule` 引用上级目录 `SchedulePCagent` 中的现有 PNG，无需重复拷贝。

## Impeccable 与 Cursor Skills

- 设计上下文：根目录 `.impeccable.md`
- 上游源码（ZIP 解压）：`vendor/impeccable-main/`
- 已复制到本项目的 Cursor skills：`.cursor/skills/`（来自上游 `.cursor/skills`）

若需更新上游，可重新下载 `main` 分支 ZIP 覆盖 `vendor/impeccable-main/`，并同步复制 `.cursor/skills`。
