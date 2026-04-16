use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Normalized desktop events (MVPv1 subset). Serialized with `type` tag for JSON/SQLite payload.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum DesktopEvent {
    AppSwitch {
        app: String,
        #[serde(default, skip_serializing_if = "Option::is_none")]
        title: Option<String>,
        at: DateTime<Utc>,
    },
    /// Clipboard changed; `text_preview` is truncated for storage. `char_len` is full UTF-8 char count when known.
    Clipboard {
        text_preview: String,
        char_len: u32,
        truncated: bool,
        at: DateTime<Utc>,
    },
}

impl DesktopEvent {
    pub fn recorded_at(&self) -> DateTime<Utc> {
        match self {
            DesktopEvent::AppSwitch { at, .. } | DesktopEvent::Clipboard { at, .. } => *at,
        }
    }

    pub fn app_switch_now(app: String, title: Option<String>) -> Self {
        DesktopEvent::AppSwitch {
            app,
            title,
            at: Utc::now(),
        }
    }

    pub fn clipboard_now(text_preview: String, char_len: u32, truncated: bool) -> Self {
        DesktopEvent::Clipboard {
            text_preview,
            char_len,
            truncated,
            at: Utc::now(),
        }
    }
}
