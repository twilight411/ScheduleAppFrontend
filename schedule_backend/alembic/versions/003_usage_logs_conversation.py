"""usage_logs: optional saved conversation for debug users

Revision ID: 003
Revises: 002
Create Date: 2026-02-12

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "003"
down_revision: Union[str, Sequence[str], None] = "002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "usage_logs",
        sa.Column("user_message", sa.Text(), nullable=True),
    )
    op.add_column(
        "usage_logs",
        sa.Column("assistant_message", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("usage_logs", "assistant_message")
    op.drop_column("usage_logs", "user_message")
