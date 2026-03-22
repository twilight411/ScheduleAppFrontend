"""创建数据库（若不存在）"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

from app.config import config


def main() -> None:
    url = config.DATABASE_URL.replace("postgresql+asyncpg://", "postgresql://")
    # 连接到默认 postgres 数据库
    base = url.rsplit("/", 1)[0] + "/postgres"
    conn = psycopg2.connect(base)
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM pg_database WHERE datname = 'schedule_app'")
    if cur.fetchone() is None:
        cur.execute("CREATE DATABASE schedule_app")
        print("数据库 schedule_app 已创建")
    else:
        print("数据库 schedule_app 已存在")
    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
