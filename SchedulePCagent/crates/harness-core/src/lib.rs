mod clipboard;
mod error;
mod event;
mod foreground;
mod recording;
mod store;

pub use error::HarnessError;
pub use event::DesktopEvent;
pub use foreground::{current_foreground, ForegroundSnapshot};
pub use recording::RecordingState;
pub use store::{AppCount, TimelineStore, WindowStats};

/// Resolves the SQLite file path. Priority:
/// 1. `HARNESS_DB_PATH` — full path to the `.db` file.
/// 2. `GUANGHE_DATA_DIR` — directory; uses `harness.db` inside it (`npm run tauri:*` 会设为仓库内 `data/`).
/// 3. Current dir is repo root (存在 `package.json`) → `./data/harness.db`（便于 `cargo run` 时在 SchedulePCagent 下落到 D 盘项目目录）。
/// 4. Fallback: `%LOCALAPPDATA%/GuangheDesktopObserve/harness.db`（仅当以上都不适用时）。
pub fn default_db_path() -> std::path::PathBuf {
    use std::path::PathBuf;

    if let Ok(p) = std::env::var("HARNESS_DB_PATH") {
        return PathBuf::from(p);
    }
    if let Ok(dir) = std::env::var("GUANGHE_DATA_DIR") {
        return PathBuf::from(dir).join("harness.db");
    }
    if let Ok(cwd) = std::env::current_dir() {
        if cwd.join("package.json").is_file() {
            return cwd.join("data").join("harness.db");
        }
    }
    let base = dirs::data_local_dir().unwrap_or_else(|| PathBuf::from("."));
    base.join("GuangheDesktopObserve").join("harness.db")
}
