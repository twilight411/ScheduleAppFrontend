"""
本机验收：临时启动后端 → POST /api/ai/chat → 检查 createdTasks 是否非空。

用法（在 schedule_backend 目录）:
  uv run python scripts/smoke_ai_chat_integration.py

依赖:
  - .env 中至少配置 MINIMAX_API_KEY / DEEPSEEK_API_KEY / OPENAI_API_KEY 之一
  - PostgreSQL 可连（DATABASE_URL），否则会话依赖会失败

退出码: 0 成功且 createdTasks 非空; 1 失败; 2 跳过（无 Key）
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Any

import httpx

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

os.chdir(ROOT)

HOST = "127.0.0.1"
PORT = 8765
BASE = f"http://{HOST}:{PORT}"


def _has_any_ai_key() -> bool:
    from app.config import config

    return bool(
        (config.MINIMAX_API_KEY or "").strip()
        or (config.DEEPSEEK_API_KEY or "").strip()
        or (config.SILICONFLOW_API_KEY or "").strip()
        or (config.OPENAI_API_KEY or "").strip()
    )


def _wait_health(client: httpx.Client, timeout_s: float = 45.0) -> bool:
    deadline = time.monotonic() + timeout_s
    while time.monotonic() < deadline:
        try:
            r = client.get(f"{BASE}/health", timeout=2.0)
            if r.status_code == 200:
                return True
        except httpx.RequestError:
            pass
        time.sleep(0.4)
    return False


def main() -> int:
    # 确保加载项目 .env
    from dotenv import load_dotenv

    load_dotenv(ROOT / ".env")

    if not _has_any_ai_key():
        print(
            "SKIP: 未在 .env 中配置 MINIMAX_API_KEY / DEEPSEEK_API_KEY / "
            "SILICONFLOW_API_KEY / OPENAI_API_KEY，无法调用真实模型。"
        )
        print("退出码 2。")
        return 2

    cmd = [
        sys.executable,
        "-m",
        "uvicorn",
        "app.main:app",
        "--host",
        HOST,
        "--port",
        str(PORT),
    ]
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    proc = subprocess.Popen(
        cmd,
        cwd=str(ROOT),
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    try:
        with httpx.Client() as client:
            if not _wait_health(client):
                err = proc.stderr.read().decode("utf-8", errors="replace") if proc.stderr else ""
                print("ERROR: 服务未在超时内就绪。", err[:2000])
                return 1

            # 固定「现在」便于模型解析「明天下午3点」
            now = datetime.now(timezone(timedelta(hours=8)))
            client_now = now.replace(microsecond=0).isoformat()

            payload: dict[str, Any] = {
                "message": "明天下午3点提醒我开会",
                "userId": "smoke-integration-user",
                "isGroupChat": True,
                "clientNowIso": client_now,
            }
            print("POST /api/ai/chat ...", flush=True)
            print("body:", json.dumps(payload, ensure_ascii=False), flush=True)

            try:
                r = client.post(
                    f"{BASE}/api/ai/chat",
                    json=payload,
                    headers={"X-User-Id": "smoke-integration-user"},
                    timeout=120.0,
                )
            except httpx.RequestError as e:
                print("ERROR: 请求失败:", e, flush=True)
                return 1

            print("HTTP", r.status_code, flush=True)
            try:
                data = r.json()
            except Exception:
                print(r.text[:4000], flush=True)
                return 1

            if r.status_code == 401 or (
                isinstance(data, dict)
                and isinstance(data.get("detail"), str)
                and ("401" in data["detail"] or "api key" in data["detail"].lower())
            ):
                print(
                    "FAIL: 上游大模型返回 401（密钥无效或未开通该接口）。"
                    "请检查 .env 中 MINIMAX_API_KEY / DEEPSEEK_API_KEY 是否为控制台里的有效 Key，"
                    "MiniMax 日程若用 OpenAI 兼容地址，需与控制台文档一致。",
                    flush=True,
                )
                print("detail:", data.get("detail") if isinstance(data, dict) else data, flush=True)
                return 1

            print("response keys:", list(data.keys()) if isinstance(data, dict) else type(data), flush=True)
            if isinstance(data, dict):
                print(
                    "response 摘要:",
                    json.dumps({k: data[k] for k in ("response", "createdTasks") if k in data}, ensure_ascii=False)[:2000],
                    flush=True,
                )

            if r.status_code != 200:
                print("detail:", data.get("detail") if isinstance(data, dict) else data, flush=True)
                return 1

            created = data.get("createdTasks") if isinstance(data, dict) else None
            if isinstance(created, list) and len(created) > 0:
                print("OK: createdTasks 非空，条数:", len(created), flush=True)
                return 0

            print(
                "FAIL: createdTasks 为空或缺失。请确认模型是否调用了 create_schedule_items，以及数据库是否写入成功。",
                flush=True,
            )
            return 1
    finally:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=12)
            except subprocess.TimeoutExpired:
                proc.kill()


if __name__ == "__main__":
    raise SystemExit(main())
