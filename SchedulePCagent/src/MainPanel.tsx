import { invoke, isTauri } from "@tauri-apps/api/core";
import { useCallback, useEffect, useState } from "react";

export default function MainPanel() {
  const [timeline, setTimeline] = useState<string>("加载中…");
  const [fg, setFg] = useState<string>("");
  const [analyze, setAnalyze] = useState<string>("");
  const [recording, setRecording] = useState<boolean>(false);
  const [aiText, setAiText] = useState<string>("");
  const [aiLoading, setAiLoading] = useState<boolean>(false);

  const refresh = useCallback(async () => {
    if (!isTauri()) {
      setTimeline(
        "当前不是 Tauri 窗口（例如在纯浏览器里打开了 Vite）。请关闭本页，在项目目录执行 npm run tauri:dev，使用弹出的桌面窗口。"
      );
      setFg("");
      setAnalyze("");
      return;
    }
    try {
      const t = await invoke<string>("get_timeline_today");
      setTimeline(t);
      const f = await invoke<string>("get_foreground_snapshot");
      setFg(f);
      const a = await invoke<string>("analyze_window_minutes", { minutes: 15 });
      setAnalyze(a);
      const on = await invoke<boolean>("get_recording_state");
      setRecording(on);
    } catch (e) {
      setTimeline(String(e));
      setFg("");
      setAnalyze("");
    }
  }, []);

  useEffect(() => {
    void refresh();
    if (!isTauri()) return;
    const id = window.setInterval(() => void refresh(), 8000);
    return () => window.clearInterval(id);
  }, [refresh]);

  const startRecording = async () => {
    if (!isTauri()) return;
    try {
      await invoke("start_recording");
      setRecording(true);
    } catch (e) {
      setTimeline(String(e));
    }
  };

  const stopRecording = async () => {
    if (!isTauri()) return;
    try {
      await invoke("stop_recording");
      setRecording(false);
      await refresh();
    } catch (e) {
      setTimeline(String(e));
    }
  };

  const runAiAnalysis = async () => {
    if (!isTauri()) return;
    setAiLoading(true);
    setAiText("");
    try {
      const t = await invoke<string>("ai_analyze_today");
      setAiText(t);
    } catch (e) {
      setAiText(String(e));
    } finally {
      setAiLoading(false);
    }
  };

  const showBubble = async () => {
    if (!isTauri()) return;
    try {
      await invoke("show_bubble_window");
    } catch (e) {
      setTimeline(String(e));
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-white to-lime-50 text-slate-800 p-8">
      <header className="mb-8">
        <h1 className="text-2xl font-semibold tracking-tight text-emerald-900">光合桌面观察</h1>
        <p className="text-sm text-emerald-800/70 mt-1">
          个人桌面时间线（调试）：前台 + 剪贴板；近 15 分钟统计约每 8s 刷新（仅 Tauri 窗口内有效）
        </p>
      </header>

      <section className="mb-6 flex flex-wrap items-center gap-3">
        {recording ? (
          <button
            type="button"
            onClick={() => void stopRecording()}
            className="px-3 py-1.5 rounded-md bg-rose-600 text-white text-sm hover:bg-rose-500 shadow-sm"
          >
            停止记录
          </button>
        ) : (
          <button
            type="button"
            onClick={() => void startRecording()}
            className="px-3 py-1.5 rounded-md bg-emerald-600 text-white text-sm hover:bg-emerald-500 shadow-sm"
          >
            开始记录
          </button>
        )}
        <span className="text-sm text-emerald-900/80">
          状态：{recording ? "记录中" : "未记录"}
        </span>
        <button
          type="button"
          onClick={() => void refresh()}
          className="px-3 py-1.5 rounded-md border border-emerald-200 bg-white/80 text-sm text-emerald-900 hover:bg-white"
        >
          立即刷新
        </button>
        <button
          type="button"
          disabled={aiLoading}
          onClick={() => void runAiAnalysis()}
          className="px-3 py-1.5 rounded-md bg-violet-600 text-white text-sm hover:bg-violet-500 shadow-sm disabled:opacity-50"
        >
          {aiLoading ? "AI 分析中…" : "AI 分析今日"}
        </button>
        <button
          type="button"
          onClick={() => void showBubble()}
          className="px-3 py-1.5 rounded-md border border-amber-300 bg-amber-50 text-sm text-amber-950 hover:bg-amber-100"
        >
          显示气泡球
        </button>
      </section>

      {aiText ? (
        <section className="mb-6">
          <h2 className="text-sm font-medium text-emerald-900/80 mb-2">方舟模型分析（豆包）</h2>
          <pre className="text-sm bg-violet-50 rounded-lg p-4 border border-violet-100 overflow-x-auto shadow-sm whitespace-pre-wrap">
            {aiText}
          </pre>
        </section>
      ) : null}

      <section className="mb-6">
        <h2 className="text-sm font-medium text-emerald-900/80 mb-2">前台快照</h2>
        <pre className="text-xs bg-white/60 rounded-lg p-4 border border-emerald-100 overflow-x-auto shadow-sm">
          {fg || "—"}
        </pre>
      </section>

      <section className="mb-6">
        <h2 className="text-sm font-medium text-emerald-900/80 mb-2">近 15 分钟（analyze）</h2>
        <pre className="text-xs bg-white/60 rounded-lg p-4 border border-emerald-100 overflow-x-auto max-h-[40vh] shadow-sm whitespace-pre-wrap">
          {analyze || "—"}
        </pre>
      </section>

      <section>
        <h2 className="text-sm font-medium text-emerald-900/80 mb-2">今日事件（JSON）</h2>
        <pre className="text-xs bg-white/60 rounded-lg p-4 border border-emerald-100 overflow-x-auto max-h-[50vh] shadow-sm whitespace-pre-wrap">
          {timeline}
        </pre>
      </section>
    </div>
  );
}
