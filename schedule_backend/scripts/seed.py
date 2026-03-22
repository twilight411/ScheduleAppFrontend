"""种子数据 - 写入少量测试用户"""
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.db.seed import run_seed


async def main() -> None:
    ok = await run_seed()
    if ok:
        print("Seed 完成：3 个用户，5 条偏好，2 条聊天记录")
    else:
        print("已有用户数据，跳过 seed")


if __name__ == "__main__":
    asyncio.run(main())
