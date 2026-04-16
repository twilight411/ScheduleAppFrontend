mod ark;

use harness_core::{current_foreground, default_db_path, RecordingState, TimelineStore};
use tauri::Manager;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

struct RecorderInner {
    stop: Option<Arc<AtomicBool>>,
    join: Option<thread::JoinHandle<()>>,
}

struct AppState {
    recorder: Mutex<RecorderInner>,
}

impl Default for AppState {
    fn default() -> Self {
        Self {
            recorder: Mutex::new(RecorderInner {
                stop: None,
                join: None,
            }),
        }
    }
}

#[tauri::command]
fn get_timeline_today() -> Result<String, String> {
    let db = default_db_path();
    let store = TimelineStore::open(&db).map_err(|e| e.to_string())?;
    let events = store.events_today_local().map_err(|e| e.to_string())?;
    serde_json::to_string_pretty(&events).map_err(|e| e.to_string())
}

#[tauri::command]
fn get_foreground_snapshot() -> Result<String, String> {
    let s = current_foreground().map_err(|e| e.to_string())?;
    serde_json::to_string(&s).map_err(|e| e.to_string())
}

#[tauri::command]
fn analyze_window_minutes(minutes: i64) -> Result<String, String> {
    if minutes < 1 || minutes > 24 * 60 {
        return Err("minutes 必须在 1..=1440 范围内".into());
    }
    let db = default_db_path();
    let store = TimelineStore::open(&db).map_err(|e| e.to_string())?;
    let stats = store
        .analyze_window_minutes(minutes)
        .map_err(|e| e.to_string())?;
    serde_json::to_string_pretty(&stats).map_err(|e| e.to_string())
}

#[tauri::command]
fn start_recording(state: tauri::State<'_, AppState>) -> Result<(), String> {
    let mut g = state.recorder.lock().map_err(|e| e.to_string())?;
    if g.join.is_some() {
        return Err("已在记录中".into());
    }
    let stop = Arc::new(AtomicBool::new(false));
    let stop_t = stop.clone();
    let db = default_db_path();
    let handle = thread::spawn(move || {
        let store = match TimelineStore::open(&db) {
            Ok(s) => s,
            Err(e) => {
                eprintln!("[harness] 打开数据库失败: {e}");
                return;
            }
        };
        let mut rec = RecordingState::new();
        while !stop_t.load(Ordering::SeqCst) {
            if let Err(e) = rec.poll_once(&store) {
                eprintln!("[harness] 采集 tick 失败: {e}");
            }
            thread::sleep(Duration::from_secs(2));
        }
    });
    g.stop = Some(stop);
    g.join = Some(handle);
    Ok(())
}

#[tauri::command]
fn stop_recording(state: tauri::State<'_, AppState>) -> Result<(), String> {
    let mut g = state.recorder.lock().map_err(|e| e.to_string())?;
    if let Some(s) = &g.stop {
        s.store(true, Ordering::SeqCst);
    }
    if let Some(h) = g.join.take() {
        h.join().map_err(|e| format!("停止记录线程: {e:?}"))?;
    }
    g.stop = None;
    Ok(())
}

#[tauri::command]
fn get_recording_state(state: tauri::State<'_, AppState>) -> Result<bool, String> {
    let g = state.recorder.lock().map_err(|e| e.to_string())?;
    Ok(g.join.is_some())
}

/// 从气泡球切回主调试窗口并聚焦。
#[tauri::command]
fn focus_main_window(app: tauri::AppHandle) -> Result<(), String> {
    let Some(w) = app.get_webview_window("main") else {
        return Err("找不到主窗口".into());
    };
    w.show().map_err(|e| e.to_string())?;
    w.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

/// 若用户点了「隐藏」，可从主窗口再次显示气泡球。
#[tauri::command]
fn show_bubble_window(app: tauri::AppHandle) -> Result<(), String> {
    let Some(w) = app.get_webview_window("bubble") else {
        return Err("找不到气泡窗口".into());
    };
    w.show().map_err(|e| e.to_string())?;
    w.set_focus().map_err(|e| e.to_string())?;
    Ok(())
}

fn truncate_chars(s: &str, max: usize) -> String {
    let mut out = String::with_capacity(max.saturating_add(32));
    for (i, ch) in s.chars().enumerate() {
        if i >= max {
            out.push_str("\n\n…(内容过长已截断，仅发送前 ");
            out.push_str(&max.to_string());
            out.push_str(" 个字符给模型)");
            break;
        }
        out.push(ch);
    }
    out
}

/// 读取今日时间线 + 近 15 分钟统计，调用火山方舟做简短中文分析。
#[tauri::command]
async fn ai_analyze_today() -> Result<String, String> {
    let db = default_db_path();
    let store = TimelineStore::open(&db).map_err(|e| e.to_string())?;
    let events = store.events_today_local().map_err(|e| e.to_string())?;
    let events_json =
        serde_json::to_string_pretty(&events).map_err(|e| e.to_string())?;
    let stats = store
        .analyze_window_minutes(15)
        .map_err(|e| e.to_string())?;
    let stats_json = serde_json::to_string_pretty(&stats).map_err(|e| e.to_string())?;

    let events_part = truncate_chars(&events_json, 18_000);
    let user_prompt = format!(
        "下面是我今天在电脑上的采集数据（桌面观察 MVP）。\n\n\
         【今日事件 JSON 数组】每个元素有 type 字段：app_switch 表示前台切换，clipboard 表示剪贴板文本变化（可能含隐私，分析时不要复述具体内容）。\n\
         {}\n\n\
         【近 15 分钟统计 JSON】\n\
         {}\n\n\
         请用中文简洁回答：\n\
         1) 当前节奏概括（1～2 句）\n\
         2) 是否像「卡住 / 分心 / 高频切换」等（若有依据）\n\
         3) 一条可执行的下一步建议（10～20 字以内优先）",
        events_part, stats_json
    );

    let system = "你是「光合桌面观察」里的节奏分析助手，只根据用户提供的结构化日志做推断，不要编造未出现的事实；对剪贴板内容保持隐私，不要逐字引用。";

    ark::chat_completion(system, &user_prompt).await
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    // 优先仓库根目录 .env（npm run tauri:dev 时 cwd 多为 SchedulePCagent）
    let _ = dotenvy::dotenv();
    let _ = dotenvy::from_path("../.env");

    tauri::Builder::default()
        .setup(|app| {
            if let Some(bubble) = app.get_webview_window("bubble") {
                let _ = bubble.set_shadow(false);
            }
            Ok(())
        })
        .manage(AppState::default())
        .invoke_handler(tauri::generate_handler![
            get_timeline_today,
            get_foreground_snapshot,
            analyze_window_minutes,
            start_recording,
            stop_recording,
            get_recording_state,
            focus_main_window,
            show_bubble_window,
            ai_analyze_today,
        ])
        .run(tauri::generate_context!())
        .expect("error while running 光合桌面观察");
}
