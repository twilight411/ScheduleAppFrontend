本目录用于存放「复制出来」的 SQLite 快照，便于用 DB 浏览器审字段。

当前程序默认主库在仓库内：
  SchedulePCagent/data/harness.db
  （及同目录下 harness.db-wal、harness.db-shm，请成套复制）

若仍使用旧路径，可能还在：
  %LOCALAPPDATA%\ScheduleHarness\harness.db*

导出 JSON 给 AI（无需上传 .db）：
  在 SchedulePCagent 下执行：npm run export:timeline-today
  输出：data/export/timeline-today-YYYY-MM-DD.json

说明文档：
  docs/数据与运行说明.md
