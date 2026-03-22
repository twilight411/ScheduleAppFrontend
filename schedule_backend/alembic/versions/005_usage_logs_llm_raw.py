"""usage_logs: store raw LLM provider JSON for admin debug

Revision ID: 005
Revises: 004
Create Date: 2026-03-20

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "005"
down_revision: Union[str, Sequence[str], None] = "004"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "usage_logs",
        sa.Column("llm_response_json", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("usage_logs", "llm_response_json")
