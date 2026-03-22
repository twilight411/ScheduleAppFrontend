"""手动初始化数据库（执行迁移 + 种子数据）"""
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.db import init_db
from app.db.seed import run_seed


async def main():
    await init_db()
    print("迁移完成")
    if await run_seed():
        print("Seed 完成：3 个用户，5 条偏好，2 条聊天记录")
    else:
        print("已有用户数据，跳过 seed")


if __name__ == "__main__":
    asyncio.run(main())
