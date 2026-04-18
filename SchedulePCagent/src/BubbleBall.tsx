/**
 * 光合日历 · 桌面气泡球（独立 Webview，label === "bubble"）
 *
 * ── 调尺寸（最重要）────────────────────────────────────────────
 * 窗口逻辑像素在 src-tauri/tauri.conf.json → app.windows → label "bubble" 的 width/height。
 * 须保持 width === height，与圆形裁切一致。改完重启 dev 或等 Tauri 重载。
 * 更细的说明见 docs/气泡球调参.md。
 *
 * ── 本文件可改项（简要）────────────────────────────────────────
 * - 根容器：rounded-full + overflow-hidden → 圆形可视区域；勿改 h-screen/w-screen（否则可能高度为 0）。
 * - 主图：object-contain 保整张图；改 object-cover 可铺满圆但可能裁切。
 * - 右键菜单：见下方 BubbleContextMenu 与 MENU_* 常量（文案、宽度、样式）；菜单用 Portal 挂 body，避免被圆形容器裁切。
 * - 精灵皮肤：images/spirit_*.png，右键「切换外观」；持久化 localStorage key GUANGHE_BUBBLE_SKIN。
 */
import { invoke, isTauri } from "@tauri-apps/api/core";
import { getCurrentWindow } from "@tauri-apps/api/window";
import { forwardRef, useCallback, useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import {
  type BubbleSkinId,
  readBubbleSkin,
  SKIN_SRC,
  SPIRIT_MENU_ITEMS,
  writeBubbleSkin,
} from "./bubbleSkins";

/** 右键菜单预估宽度（用于贴边clamp，与下方 Tailwind min-w 大致一致） */
const MENU_ESTIMATE_W = 152;
/** 顶栏 + 功能项 + 切换外观区块（改菜单结构时同步改这里，便于贴边 clamp） */
const MENU_ESTIMATE_H = 300;

type MenuPos = { x: number; y: number };

function clampMenuPosition(clientX: number, clientY: number): MenuPos {
  const vw = window.innerWidth;
  const vh = window.innerHeight;
  let x = clientX;
  let y = clientY;
  x = Math.min(x, vw - MENU_ESTIMATE_W - 4);
  y = Math.min(y, vh - MENU_ESTIMATE_H - 4);
  x = Math.max(4, x);
  y = Math.max(4, y);
  return { x, y };
}

export default function BubbleBall() {
  const [menuPos, setMenuPos] = useState<MenuPos | null>(null);
  const [skinId, setSkinId] = useState<BubbleSkinId>(() => readBubbleSkin());
  const menuPanelRef = useRef<HTMLDivElement>(null);

  const setSkin = useCallback((id: BubbleSkinId) => {
    setSkinId(id);
    writeBubbleSkin(id);
  }, []);

  /**
   * 小窗内 #root 默认无高度，h-full 会塌成 0；这里把 html/body/#root 拉满，
   * 与外层 h-screen 双保险。仅气泡窗口进程会执行，不影响主窗口。
   */
  useEffect(() => {
    const root = document.getElementById("root");
    document.documentElement.style.background = "transparent";
    document.documentElement.style.height = "100%";
    document.body.style.background = "transparent";
    document.body.style.height = "100%";
    document.body.style.margin = "0";
    document.body.style.overflow = "hidden";
    if (root) {
      root.style.height = "100%";
      root.style.minHeight = "100%";
      root.style.overflow = "hidden";
    }
    return () => {
      document.documentElement.style.height = "";
      document.documentElement.style.background = "";
      document.body.style.height = "";
      document.body.style.overflow = "";
      document.body.style.background = "";
      if (root) {
        root.style.height = "";
        root.style.minHeight = "";
        root.style.overflow = "";
      }
    };
  }, []);

  const closeMenu = useCallback(() => setMenuPos(null), []);

  /** 菜单打开时：点外部关闭、Esc 关闭 */
  useEffect(() => {
    if (!menuPos) return;
    const onMouseDown = (e: MouseEvent) => {
      if (menuPanelRef.current?.contains(e.target as Node)) return;
      closeMenu();
    };
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") closeMenu();
    };
    document.addEventListener("mousedown", onMouseDown, true);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("mousedown", onMouseDown, true);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [menuPos, closeMenu]);

  const openMain = useCallback(async () => {
    if (!isTauri()) return;
    try {
      await invoke("focus_main_window");
    } catch {
      /* ignore */
    }
  }, []);

  const hideBubble = useCallback(async () => {
    if (!isTauri()) return;
    try {
      await getCurrentWindow().hide();
    } catch {
      /* ignore */
    }
  }, []);

  const onOpenMain = useCallback(() => {
    closeMenu();
    void openMain();
  }, [closeMenu, openMain]);

  const onHideBubble = useCallback(() => {
    closeMenu();
    void hideBubble();
  }, [closeMenu, hideBubble]);

  const onSelectSkin = useCallback(
    (id: BubbleSkinId) => {
      setSkin(id);
      closeMenu();
    },
    [closeMenu, setSkin]
  );

  const onRestoreInitialSkin = useCallback(() => {
    onSelectSkin("initial");
  }, [onSelectSkin]);

  const onContextMenu = useCallback((e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    const p = clampMenuPosition(e.clientX, e.clientY);
    setMenuPos(p);
  }, []);

  return (
    <>
      {/* 视口 = 窗口客户区；须 h-screen w-screen，勿改成 h-full */}
      <div
        className="relative h-screen w-screen select-none overflow-hidden rounded-full"
        style={{ background: "transparent", boxShadow: "none" }}
      >
        {/*
          data-tauri-drag-region：整块可拖动窗口。
          双击：打开主窗口。右键：功能菜单（不在球面上常驻按钮）。
        */}
        <button
          type="button"
          data-tauri-drag-region
          className="absolute inset-0 m-0 flex items-center justify-center rounded-full border-0 bg-transparent p-0 cursor-grab shadow-none active:cursor-grabbing"
          style={{ boxShadow: "none" }}
          onDoubleClick={() => void openMain()}
          onContextMenu={onContextMenu}
          title="右键打开菜单；拖动移动；双击打开主窗口"
          aria-label="光合日历气泡球，右键菜单，拖动移动，双击打开主窗口"
          aria-haspopup="menu"
          aria-expanded={menuPos != null}
        >
          {/*
            object-contain：整图缩进圆内，可能上下或左右留透明隙。
            若希望铺满圆可改为 object-cover（可能裁掉边缘）。
          */}
          <img
            src={SKIN_SRC[skinId]}
            alt=""
            className="pointer-events-none h-full w-full rounded-full object-contain shadow-none"
            style={{ filter: "none" }}
            draggable={false}
          />
        </button>
      </div>

      {menuPos != null
        ? createPortal(
            <BubbleContextMenu
              ref={menuPanelRef}
              x={menuPos.x}
              y={menuPos.y}
              skinId={skinId}
              onOpenMain={onOpenMain}
              onHideBubble={onHideBubble}
              onSelectSkin={onSelectSkin}
              onRestoreInitialSkin={onRestoreInitialSkin}
            />,
            document.body
          )
        : null}
    </>
  );
}

type BubbleContextMenuProps = {
  x: number;
  y: number;
  skinId: BubbleSkinId;
  onOpenMain: () => void;
  onHideBubble: () => void;
  onSelectSkin: (id: BubbleSkinId) => void;
  onRestoreInitialSkin: () => void;
};

/** 挂到 document.body，避免被气泡根节点 overflow-hidden + rounded-full 裁掉 */
const BubbleContextMenu = forwardRef<HTMLDivElement, BubbleContextMenuProps>(
  function BubbleContextMenu(
    {
      x,
      y,
      skinId,
      onOpenMain,
      onHideBubble,
      onSelectSkin,
      onRestoreInitialSkin,
    },
    ref
  ) {
    return (
      <div
        ref={ref}
        role="menu"
        aria-label="气泡球功能"
        className="fixed z-[9999] min-w-[148px] overflow-hidden rounded-lg border border-slate-200/90 bg-white/95 py-1 text-left text-slate-800 shadow-lg shadow-slate-900/15 backdrop-blur-sm"
        style={{ left: x, top: y }}
      >
        <div className="border-b border-slate-100 px-3 py-1.5 text-[11px] font-medium text-slate-500">
          光合日历
        </div>
        <button
          type="button"
          role="menuitem"
          className="block w-full px-3 py-2 text-left text-[13px] hover:bg-emerald-50 active:bg-emerald-100"
          onClick={onOpenMain}
        >
          打开主界面
        </button>
        <button
          type="button"
          role="menuitem"
          className="block w-full px-3 py-2 text-left text-[13px] hover:bg-emerald-50 active:bg-emerald-100"
          onClick={onHideBubble}
        >
          隐藏气泡球
        </button>
        <div
          className="border-t border-slate-100 px-3 py-1.5 text-[11px] font-medium text-slate-500"
          role="presentation"
        >
          切换外观
        </div>
        {SPIRIT_MENU_ITEMS.map(({ id, label }) => {
          const active = skinId === id;
          return (
            <button
              key={id}
              type="button"
              role="menuitemradio"
              aria-checked={active}
              className={`block w-full px-3 py-2 text-left text-[13px] hover:bg-emerald-50 active:bg-emerald-100 ${
                active ? "bg-emerald-50/80 font-medium text-emerald-900" : ""
              }`}
              onClick={() => onSelectSkin(id)}
            >
              {label}
            </button>
          );
        })}
        <button
          type="button"
          role="menuitem"
          className="block w-full border-t border-slate-100 px-3 py-1.5 text-left text-[11px] text-slate-500 hover:bg-slate-50 hover:text-slate-700"
          onClick={onRestoreInitialSkin}
        >
          恢复初始外观
        </button>
      </div>
    );
  }
);
