"""user schedule tasks (AI + manual)

Revision ID: 004
Revises: 003
Create Date: 2026-02-12

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "004"
down_revision: Union[str, Sequence[str], None] = "003"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "schedule_tasks",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.String(64), nullable=False),
        sa.Column("title", sa.String(256), nullable=False),
        sa.Column("description", sa.Text(), nullable=False, server_default=""),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("category", sa.String(32), nullable=False, server_default="light"),
        sa.Column("repeat_option", sa.String(32), nullable=False, server_default="never"),
        sa.Column("is_all_day", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        op.f("ix_schedule_tasks_user_id"), "schedule_tasks", ["user_id"], unique=False
    )
    op.create_index(
        op.f("ix_schedule_tasks_start_at"), "schedule_tasks", ["start_at"], unique=False
    )


def downgrade() -> None:
    op.drop_index(op.f("ix_schedule_tasks_start_at"), table_name="schedule_tasks")
    op.drop_index(op.f("ix_schedule_tasks_user_id"), table_name="schedule_tasks")
    op.drop_table("schedule_tasks")
