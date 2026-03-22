"""用户仓储 - 使用 ORM，不写原生 SQL"""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User


class UserRepository:
    """用户数据访问"""

    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, user_id: str) -> User | None:
        result = await self._session.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    async def create(self, user_id: str, nickname: str | None = None) -> User:
        user = User(id=user_id, nickname=nickname)
        self._session.add(user)
        await self._session.flush()
        await self._session.refresh(user)
        return user

    async def get_or_create(self, user_id: str, nickname: str | None = None) -> User:
        user = await self.get_by_id(user_id)
        if user is None:
            user = await self.create(user_id, nickname)
        return user
