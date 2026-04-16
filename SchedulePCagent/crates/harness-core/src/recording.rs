//! One polling tick: foreground app_switch + clipboard (Windows), shared by CLI and Tauri.

use crate::clipboard::{clipboard_sequence_number, try_read_unicode_clipboard_event};
use crate::current_foreground;
use crate::error::Result;
use crate::event::DesktopEvent;
use crate::store::TimelineStore;

/// Tracks last seen foreground and clipboard sequence so we only persist on change.
#[derive(Debug, Default)]
pub struct RecordingState {
    last_fg: Option<(String, Option<String>)>,
    last_clipboard_seq: Option<u32>,
}

impl RecordingState {
    pub fn new() -> Self {
        Self::default()
    }

    /// Poll once: insert `app_switch` / `clipboard` rows when changed.
    pub fn poll_once(&mut self, store: &TimelineStore) -> Result<()> {
        let fg = current_foreground()?;
        let key = (fg.app.clone(), fg.title.clone());
        if self.last_fg.as_ref() != Some(&key) {
            self.last_fg = Some(key.clone());
            store.insert_event(&DesktopEvent::app_switch_now(fg.app, fg.title))?;
        }

        let seq = clipboard_sequence_number()?;
        match self.last_clipboard_seq {
            None => {
                self.last_clipboard_seq = Some(seq);
            }
            Some(prev) if seq != prev => {
                self.last_clipboard_seq = Some(seq);
                if let Some(ev) = try_read_unicode_clipboard_event()? {
                    store.insert_event(&ev)?;
                }
            }
            _ => {}
        }

        Ok(())
    }
}
