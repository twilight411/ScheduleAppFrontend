"""Alembic 迁移环境配置"""
from logging.config import fileConfig

from alembic import context
from sqlalchemy import pool
from sqlalchemy.engine import Connection

from app.config import config as app_config
from app.db.session import Base

# 导入所有模型以注册到 metadata
from app.db import models  # noqa: F401

alembic_config = context.config
alembic_config.set_main_option(
    "sqlalchemy.url",
    app_config.DATABASE_URL.replace("postgresql+asyncpg", "postgresql"),
)

if alembic_config.config_file_name is not None:
    fileConfig(alembic_config.config_file_name)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """离线模式：生成 SQL 脚本"""
    url = alembic_config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


async def run_async_migrations() -> None:
    """在线模式：使用 sync 连接"""
    connectable = alembic_config.get_main_option("sqlalchemy.url")
    connectable = connectable.replace("postgresql+asyncpg", "postgresql")
    configuration = alembic_config.get_section(alembic_config.config_ini_section, {})
    configuration["sqlalchemy.url"] = connectable

    from sqlalchemy import create_engine
    connectable = create_engine(connectable, poolclass=pool.NullPool)
    with connectable.connect() as connection:
        do_run_migrations(connection)


def run_migrations_online() -> None:
    """在线模式入口"""
    connectable = alembic_config.get_main_option("sqlalchemy.url")
    connectable = connectable.replace("postgresql+asyncpg", "postgresql")
    configuration = alembic_config.get_section(alembic_config.config_ini_section, {})
    configuration["sqlalchemy.url"] = connectable

    from sqlalchemy import create_engine
    connectable = create_engine(connectable, poolclass=pool.NullPool)
    with connectable.connect() as connection:
        do_run_migrations(connection)


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
