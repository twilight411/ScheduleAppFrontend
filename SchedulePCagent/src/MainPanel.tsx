import { invoke, isTauri } from "@tauri-apps/api/core";
import { useCallback, useEffect, useMemo, useState } from "react";
import { readBubbleSkin, SKIN_SRC } from "./bubbleSkins";

const DISPLAY_NAME = "zyx";

type NavId = "home" | "agent" | "rewind" | "tasks";
type CenterFilter = "events" | 15 | 30 | 60;

type DesktopEventJson =
  | { type: "app_switch"; app: string; title?: string | null; at: string }
  | {
      type: "clipboard";
      text_preview: string;
      char_len: number;
      truncated: boolean;
      at: string;
    };

interface WindowStats {
  window_minutes: number;
  app_switch_count: number;
  clipboard_event_count: number;
  dominant_apps: { app: string; count: number }[];
}

function greetingForNow(): string {
  const h = new Date().getHours();
  if (h < 12) return "早上好";
  if (h < 18) return "下午好";
  return "晚上好";
}

function formatZhDate(d: Date): string {
  return `${d.getMonth() + 1}月${d.getDate()}日`;
}

function parseTimelineEvents(raw: string): DesktopEventJson[] | null {
  if (!raw || raw.startsWith("加载") || raw.startsWith("当前不是")) return null;
  try {
    const v = JSON.parse(raw) as unknown;
    if (!Array.isArray(v)) return null;
    return v as DesktopEventJson[];
  } catch {
    return null;
  }
}

function parseWindowStats(raw: string): WindowStats | null {
  if (!raw || raw === "—") return null;
  try {
    return JSON.parse(raw) as WindowStats;
  } catch {
    return null;
  }
}

function eventSummary(ev: DesktopEventJson): string {
  if (ev.type === "app_switch") {
    const t = ev.title?.trim();
    return t ? `${ev.app} · ${t}` : ev.app;
  }
  const prev =
    ev.text_preview.length > 48
      ? `${ev.text_preview.slice(0, 48)}…`
      : ev.text_preview;
  return `剪贴板 · ${prev}`;
}

function eventTimeLocal(ev: DesktopEventJson): string {
  try {
    const d = new Date(ev.at);
    return d.toLocaleTimeString("zh-CN", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  } catch {
    return "—";
  }
}

// --- icons (inline SVG, AirJelly-like minimal strokes) ---

function IconPanelLeft({ className }: { className?: string }) {
  return (
    <svg className={className} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <rect x="3" y="4" width="18" height="16" rx="2" />
      <path d="M9 4v16" />
    </svg>
  );
}

function IconHome({ className }: { className?: string }) {
  return (
    <svg className={className} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 10.5L12 3l9 7.5" />
      <path d="M5 10v10h14V10" />
    </svg>
  );
}

function IconAgent({ className }: { className?: string }) {
  return (
    <svg className={className} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <path d="M5 9h14M8 14h8M6 19h12" />
      <path d="M4 5h4v4H4z" />
    </svg>
  );
}

function IconRewind({ className }: { className?: string }) {
  return (
    <svg className={className} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <circle cx="12" cy="12" r="8" />
      <path d="M12 8v4l3 2" />
      <path d="M6 12a6 6 0 0 1 6-6" />
    </svg>
  );
}

function IconTasks({ className }: { className?: string }) {
  return (
    <svg className={className} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <path d="M8 6h13M8 12h13M8 18h13" />
      <path d="M3 6h1M3 12h1M3 18h1" />
    </svg>
  );
}

function IconFolderPlus({ className }: { className?: string }) {
  return (
    <svg className={className} width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <path d="M4 20h16a1 1 0 0 0 1-1V7a1 1 0 0 0-1-1h-7l-2-2H4a1 1 0 0 0-1 1v13a1 1 0 0 0 1 1z" />
      <path d="M12 10v6M9 13h6" />
    </svg>
  );
}

function IconCalendar({ className }: { className?: string }) {
  return (
    <svg className={className} width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M16 3v4M8 3v4M3 11h18" />
    </svg>
  );
}

function IconBell({ className }: { className?: string }) {
  return (
    <svg className={className} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 7-3 7h18s-3 0-3-7" />
      <path d="M13.73 21a2 2 0 0 1-3.46 0" />
    </svg>
  );
}

function IconClockEmpty({ className }: { className?: string }) {
  return (
    <svg className={className} width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.25" strokeLinecap="round">
      <circle cx="12" cy="12" r="9" />
      <path d="M12 7v6l4 2" />
    </svg>
  );
}

function LogoJelly({ className }: { className?: string }) {
  return (
    <svg className={className} width="28" height="28" viewBox="0 0 32 32" fill="none" aria-hidden>
      <ellipse cx="16" cy="14" rx="10" ry="8" fill="#3b82f6" opacity="0.92" />
      <path
        d="M8 20c2 4 6 6 8 6s6-2 8-6"
        stroke="#2563eb"
        strokeWidth="1.5"
        strokeLinecap="round"
        fill="none"
      />
      <circle cx="12" cy="13" r="1.5" fill="white" />
      <circle cx="20" cy="13" r="1.5" fill="white" />
      <path d="M10 22l-2 6M14 23l-1 5M18 23l1 5M22 22l2 6" stroke="#60a5fa" strokeWidth="1.2" strokeLinecap="round" />
    </svg>
  );
}

function ToggleSwitch({
  on,
  onToggle,
  disabled,
  ariaLabel,
}: {
  on: boolean;
  onToggle: () => void;
  disabled?: boolean;
  ariaLabel: string;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      aria-label={ariaLabel}
      disabled={disabled}
      onClick={onToggle}
      className={`relative h-7 w-12 shrink-0 rounded-full transition-colors ${
        on ? "bg-[#3b82f6]" : "bg-neutral-300"
      } ${disabled ? "opacity-50 cursor-not-allowed" : "cursor-pointer"}`}
    >
      <span
        className={`absolute top-0.5 h-6 w-6 rounded-full bg-white shadow transition-transform ${
          on ? "left-5" : "left-0.5"
        }`}
      />
    </button>
  );
}

export default function MainPanel() {
  const [nav, setNav] = useState<NavId>("home");
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [centerFilter, setCenterFilter] = useState<CenterFilter>("events");
  const [displayDate] = useState(() => new Date());

  const [timeline, setTimeline] = useState<string>("加载中…");
  const [fg, setFg] = useState<string>("");
  const [analyze, setAnalyze] = useState<string>("");
  const [recording, setRecording] = useState<boolean>(false);
  const [aiText, setAiText] = useState<string>("");
  const [aiLoading, setAiLoading] = useState<boolean>(false);
  const [bubbleSkin, setBubbleSkin] = useState(() => readBubbleSkin());

  const analyzeMinutes = centerFilter === "events" ? 15 : centerFilter;

  const refresh = useCallback(async () => {
    setBubbleSkin(readBubbleSkin());
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
      const mins = analyzeMinutes;
      const a = await invoke<string>("analyze_window_minutes", { minutes: mins });
      setAnalyze(a);
      const on = await invoke<boolean>("get_recording_state");
      setRecording(on);
    } catch (e) {
      setTimeline(String(e));
      setFg("");
      setAnalyze("");
    }
  }, [analyzeMinutes]);

  useEffect(() => {
    void refresh();
    if (!isTauri()) return;
    const id = window.setInterval(() => void refresh(), 8000);
    return () => window.clearInterval(id);
  }, [refresh]);

  const events = useMemo(() => parseTimelineEvents(timeline), [timeline]);
  const stats = useMemo(() => parseWindowStats(analyze), [analyze]);
  const todayCount = events?.length ?? 0;
  const loadingTimeline = timeline.startsWith("加载");
  const nonTauriHint = timeline.startsWith("当前不是");
  const timelineParseError =
    !loadingTimeline && !nonTauriHint && events === null;

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

  const toggleRecording = () => {
    if (recording) void stopRecording();
    else void startRecording();
  };

  const navBtn = (id: NavId, label: string, Icon: typeof IconHome) => {
    const active = nav === id;
    return (
      <button
        type="button"
        onClick={() => setNav(id)}
        className={`flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium transition-colors ${
          active
            ? "bg-neutral-100 text-neutral-900"
            : "text-neutral-600 hover:bg-neutral-50 hover:text-neutral-900"
        }`}
      >
        <Icon className={active ? "text-neutral-900" : "text-neutral-500"} />
        {!sidebarCollapsed ? <span>{label}</span> : null}
      </button>
    );
  };

  const filterBtn = (id: CenterFilter, label: string) => {
    const active = centerFilter === id;
    return (
      <button
        type="button"
        onClick={() => setCenterFilter(id)}
        className={`rounded-lg px-3 py-1.5 text-[12px] font-medium transition-colors ${
          active
            ? "bg-neutral-900 text-white"
            : "bg-white text-neutral-600 ring-1 ring-neutral-200 hover:bg-neutral-50"
        }`}
      >
        {label}
      </button>
    );
  };

  return (
    <div className="flex min-h-screen bg-[#f4f4f5] text-neutral-900 antialiased">
      {/*左侧栏 */}
      <aside
        className={`flex shrink-0 flex-col border-r border-neutral-200/90 bg-white ${
          sidebarCollapsed ? "w-[72px]" : "w-[248px]"
        }`}
      >
        <div className="flex h-14 items-center justify-between gap-2 border-b border-neutral-100 px-3">
          <div className={`flex min-w-0 items-center gap-2 ${sidebarCollapsed ? "justify-center" : ""}`}>
            <LogoJelly />
            {!sidebarCollapsed ? (
              <span className="truncate text-[15px] font-semibold tracking-tight text-neutral-900">
                光合桌面
              </span>
            ) : null}
          </div>
          {!sidebarCollapsed ? (
            <button
              type="button"
              onClick={() => setSidebarCollapsed(true)}
              className="rounded-lg p-1.5 text-neutral-500 hover:bg-neutral-100 hover:text-neutral-800"
              aria-label="收起侧栏"
            >
              <IconPanelLeft className="h-4 w-4" />
            </button>
          ) : (
            <button
              type="button"
              onClick={() => setSidebarCollapsed(false)}
              className="mx-auto rounded-lg p-1.5 text-neutral-500 hover:bg-neutral-100"
              aria-label="展开侧栏"
            >
              <IconPanelLeft className="h-4 w-4" />
            </button>
          )}
        </div>

        <nav className="flex flex-1 flex-col gap-0.5 p-2">
          {navBtn("home", "首页", IconHome)}
          {navBtn("agent", "助手", IconAgent)}
          {navBtn("rewind", "回顾", IconRewind)}
          {navBtn("tasks", "任务", IconTasks)}

          <div className={`mt-4 px-2 ${sidebarCollapsed ? "hidden" : ""}`}>
            <div className="mb-1 flex items-center justify-between text-[11px] font-semibold uppercase tracking-wide text-neutral-400">
              <span>会话</span>
              <IconFolderPlus className="text-neutral-400" />
            </div>
            <p className="rounded-lg bg-neutral-50 px-2 py-3 text-center text-[12px] text-neutral-400">
              暂无活动会话
            </p>
          </div>
        </nav>

        <div className="border-t border-neutral-100 p-3">
          {!sidebarCollapsed ? (
            <button
              type="button"
              className="mb-3 w-full rounded-xl border border-neutral-200 bg-white px-3 py-2 text-left text-[12px] text-neutral-600 hover:bg-neutral-50"
            >
              向光合桌面发送反馈
            </button>
          ) : null}
          <div className={`flex items-center gap-2 ${sidebarCollapsed ? "justify-center" : ""}`}>
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-[#3b82f6] text-[13px] font-semibold text-white">
              {DISPLAY_NAME.slice(0, 1).toUpperCase()}
            </div>
            {!sidebarCollapsed ? (
              <span className="truncate text-[13px] font-medium text-neutral-800">{DISPLAY_NAME}</span>
            ) : null}
          </div>
        </div>
      </aside>

      {/* 中间 + 右侧 */}
      <div className="flex min-w-0 flex-1">
        <main className="min-w-0 flex-1 overflow-auto p-6">
          {nav === "home" ? (
            <>
              <div className="mb-6 flex flex-wrap items-start justify-between gap-4">
                <h1 className="text-[26px] font-semibold tracking-tight text-neutral-900">
                  {greetingForNow()}，{DISPLAY_NAME}
                </h1>
                <div className="flex flex-wrap items-center gap-2">
                  {filterBtn("events", "事件")}
                  {filterBtn(15, "15 分钟")}
                  {filterBtn(30, "30 分钟")}
                  {filterBtn(60, "1 小时")}
                  <div className="ml-1 flex items-center gap-1 rounded-lg bg-white px-2 py-1 ring-1 ring-neutral-200">
                    <button
                      type="button"
                      className="rounded p-1 text-neutral-400 hover:bg-neutral-50 hover:text-neutral-700"
                      aria-label="上一天"
                    >
                      ‹
                    </button>
                    <IconCalendar className="text-neutral-500" />
                    <span className="min-w-[4.5rem] text-center text-[12px] font-medium text-neutral-800">
                      {formatZhDate(displayDate)}
                    </span>
                    <button
                      type="button"
                      className="rounded p-1 text-neutral-400 hover:bg-neutral-50 hover:text-neutral-700"
                      aria-label="下一天"
                    >
                      ›
                    </button>
                  </div>
                </div>
              </div>

              <div className="rounded-2xl border border-neutral-200/80 bg-white p-6 shadow-sm min-h-[420px]">
                {centerFilter === "events" ? (
                  <>
                    {loadingTimeline ? (
                      <div className="flex h-[360px] items-center justify-center text-sm text-neutral-400">
                        加载中…
                      </div>
                    ) : nonTauriHint ? (
                      <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
                        <p className="text-[13px] leading-relaxed text-neutral-600">{timeline}</p>
                      </div>
                    ) : timelineParseError ? (
                      <div className="flex flex-col items-center justify-center py-16 text-center">
                        <p className="text-[13px] font-medium text-neutral-700">无法加载今日事件</p>
                        <pre className="mt-3 max-h-[200px] max-w-full overflow-auto rounded-lg bg-neutral-50 px-3 py-2 text-left text-[11px] text-neutral-600">
                          {timeline}
                        </pre>
                      </div>
                    ) : events!.length === 0 ? (
                      <div className="flex flex-col items-center justify-center py-20 text-center">
                        <IconClockEmpty className="mb-4 text-neutral-300" />
                        <p className="text-[15px] font-medium text-neutral-700">暂无事件</p>
                        <p className="mt-1 max-w-sm text-[13px] text-neutral-500">
                          开始桌面记录后，应用切换与剪贴板事件将显示在这里
                        </p>
                      </div>
                    ) : (
                      <ul className="max-h-[480px] space-y-1 overflow-auto pr-1">
                        {events!.slice()
                          .reverse()
                          .map((ev, i) => (
                            <li
                              key={`${ev.at}-${i}`}
                              className="flex gap-3 rounded-xl border border-transparent px-3 py-2.5 hover:border-neutral-100 hover:bg-neutral-50"
                            >
                              <span className="w-[72px] shrink-0 font-mono text-[11px] text-neutral-400">
                                {eventTimeLocal(ev)}
                              </span>
                              <span className="min-w-0 flex-1 text-[13px] text-neutral-800">
                                {eventSummary(ev)}
                              </span>
                            </li>
                          ))}
                      </ul>
                    )}
                  </>
                ) : stats ? (
                  <div className="space-y-6">
                    <p className="text-[13px] text-neutral-500">
                      近 {stats.window_minutes} 分钟 · 应用切换{" "}
                      <strong className="text-neutral-800">{stats.app_switch_count}</strong> 次 · 剪贴板{" "}
                      <strong className="text-neutral-800">{stats.clipboard_event_count}</strong> 次
                    </p>
                    <div>
                      <h3 className="mb-2 text-[12px] font-semibold text-neutral-500">主导应用 Top 10</h3>
                      <ul className="space-y-1">
                        {stats.dominant_apps.length === 0 ? (
                          <li className="text-[13px] text-neutral-400">暂无数据</li>
                        ) : (
                          stats.dominant_apps.map((row) => (
                            <li
                              key={row.app}
                              className="flex justify-between rounded-lg bg-neutral-50 px-3 py-2 text-[13px]"
                            >
                              <span className="truncate text-neutral-800">{row.app}</span>
                              <span className="shrink-0 font-medium tabular-nums text-neutral-600">
                                {row.count}
                              </span>
                            </li>
                          ))
                        )}
                      </ul>
                    </div>
                  </div>
                ) : (
                  <div className="flex h-[360px] items-center justify-center text-sm text-neutral-400">
                    暂无统计数据
                  </div>
                )}
              </div>
            </>
          ) : null}

          {nav === "agent" ? (
            <div className="space-y-6">
              <h1 className="text-[22px] font-semibold text-neutral-900">助手 · 调试</h1>
              <div className="flex flex-wrap gap-2">
                <button
                  type="button"
                  disabled={aiLoading}
                  onClick={() => void runAiAnalysis()}
                  className="rounded-xl bg-[#3b82f6] px-4 py-2 text-[13px] font-medium text-white hover:bg-blue-600 disabled:opacity-50"
                >
                  {aiLoading ? "AI 分析中…" : "AI 分析今日"}
                </button>
                <button
                  type="button"
                  onClick={() => void showBubble()}
                  className="rounded-xl border border-neutral-200 bg-white px-4 py-2 text-[13px] font-medium text-neutral-800 hover:bg-neutral-50"
                >
                  显示桌面气泡球
                </button>
                <button
                  type="button"
                  onClick={() => void refresh()}
                  className="rounded-xl border border-neutral-200 bg-white px-4 py-2 text-[13px] font-medium text-neutral-800 hover:bg-neutral-50"
                >
                  立即刷新
                </button>
              </div>
              {aiText ? (
                <section>
                  <h2 className="mb-2 text-[12px] font-semibold text-neutral-500">方舟模型分析</h2>
                  <pre className="max-h-[40vh] overflow-auto whitespace-pre-wrap rounded-2xl border border-neutral-200 bg-neutral-50 p-4 text-[12px] text-neutral-800">
                    {aiText}
                  </pre>
                </section>
              ) : null}
              <section>
                <h2 className="mb-2 text-[12px] font-semibold text-neutral-500">前台快照</h2>
                <pre className="max-h-[30vh] overflow-auto rounded-2xl border border-neutral-200 bg-white p-4 text-[11px] text-neutral-800">
                  {fg || "—"}
                </pre>
              </section>
              <section>
                <h2 className="mb-2 text-[12px] font-semibold text-neutral-500">今日事件（JSON）</h2>
                <pre className="max-h-[40vh] overflow-auto whitespace-pre-wrap rounded-2xl border border-neutral-200 bg-white p-4 text-[11px] text-neutral-800">
                  {timeline}
                </pre>
              </section>
            </div>
          ) : null}

          {nav === "rewind" ? (
            <PlaceholderPage title="回顾" hint="时间线回放与检索将在此呈现。" />
          ) : null}
          {nav === "tasks" ? (
            <PlaceholderPage title="任务" hint="与日程、待办联动后将在此展示。" />
          ) : null}
        </main>

        {/* 右侧栏 */}
        <aside className="w-[280px] shrink-0 border-l border-neutral-200/90 bg-white p-4 lg:w-[300px] lg:p-5">
          <div className="rounded-2xl border border-neutral-200/90 bg-white p-4 shadow-sm">
            <div className="mb-3 flex items-start justify-between gap-2">
              <div>
                <h2 className="text-[13px] font-semibold text-neutral-900">桌面光合精灵</h2>
                <p className="text-[11px] text-neutral-500">气泡球与记录联动</p>
              </div>
              <ToggleSwitch
                on={recording}
                onToggle={() => toggleRecording()}
                disabled={!isTauri()}
                ariaLabel={recording ? "停止记录" : "开始记录"}
              />
            </div>
            <div className="flex justify-center py-2">
              <div className="relative h-[120px] w-[120px] overflow-hidden rounded-full bg-[#eff6ff] ring-1 ring-blue-100">
                <img
                  src={SKIN_SRC[bubbleSkin]}
                  alt=""
                  className="h-full w-full object-contain"
                  draggable={false}
                />
              </div>
            </div>
            <div className="mt-2 flex items-center justify-center gap-3 text-[12px] text-neutral-600">
              <span>
今日 <strong className="text-neutral-900 tabular-nums">{todayCount}</strong>
              </span>
              <span className="h-3 w-px bg-neutral-200" />
              <span>
                总计 <strong className="text-neutral-900 tabular-nums">{todayCount}</strong>
              </span>
            </div>
            <button
              type="button"
              onClick={() => void showBubble()}
              className="mt-3 w-full rounded-xl border border-neutral-200 py-2 text-[12px] font-medium text-neutral-700 hover:bg-neutral-50"
            >
              切换情绪
            </button>
            <p className="mt-2 text-center text-[10px] text-neutral-400">精灵外观在气泡上右键切换</p>
          </div>

          <div className="mt-5">
            <h2 className="mb-2 text-[13px] font-semibold text-neutral-900">主动助手</h2>
            <div className="rounded-2xl border border-neutral-200/90 bg-neutral-50/80 p-4">
              <p className="text-[12px] leading-relaxed text-neutral-600">
                我需要一点时间来收集你的节奏与上下文…
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                <span className="rounded-full bg-blue-100 px-2.5 py-0.5 text-[11px] font-medium text-blue-800">
                  待处理
                </span>
                <span className="inline-flex items-center gap-1 rounded-full bg-white px-2.5 py-0.5 text-[11px] font-medium text-neutral-600 ring-1 ring-neutral-200">
                  <IconBell className="h-3 w-3 text-neutral-400" />
                  执行{" "}
                  {new Date().toLocaleTimeString("zh-CN", { hour: "2-digit", minute: "2-digit" })}
                </span>
              </div>
            </div>
          </div>
        </aside>
      </div>
    </div>
  );
}

function PlaceholderPage({ title, hint }: { title: string; hint: string }) {
  return (
    <div className="rounded-2xl border border-dashed border-neutral-200 bg-white/80 p-12 text-center">
      <h1 className="text-[22px] font-semibold text-neutral-900">{title}</h1>
      <p className="mt-2 text-[13px] text-neutral-500">{hint}</p>
    </div>
  );
}
