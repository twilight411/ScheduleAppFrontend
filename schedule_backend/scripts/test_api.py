"""命令行测试所有 API 接口"""
import sys
from pathlib import Path

import httpx

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

BASE = "http://localhost:8000"


def test(name: str, method: str, url: str, **kwargs) -> None:
    print(f"\n{'='*50}")
    print(f"【{name}】 {method} {url}")
    print("=" * 50)
    try:
        if method == "GET":
            r = httpx.get(url, timeout=10, **kwargs)
        else:
            r = httpx.post(url, timeout=30, **kwargs)
        print(f"状态码: {r.status_code}")
        print(f"响应: {r.text[:500]}" + ("..." if len(r.text) > 500 else ""))
    except Exception as e:
        print(f"错误: {e}")


def main():
    print("Schedule App API 接口测试")
    print("确保后端已启动: uv run python run.py")

    test("健康检查", "GET", f"{BASE}/health")
    test("根路径", "GET", f"{BASE}/")
    test("用量统计", "GET", f"{BASE}/api/admin/usage/stats?days=7")
    test("按用户用量", "GET", f"{BASE}/api/admin/usage/by-user?days=7")
    test("按日趋势", "GET", f"{BASE}/api/admin/usage/daily?days=7")
    test(
        "AI 聊天",
        "POST",
        f"{BASE}/api/ai/chat",
        json={"message": "你好，说一句话"},
    )

    print("\n" + "=" * 50)
    print("测试完成")
    print("=" * 50)


if __name__ == "__main__":
    main()
