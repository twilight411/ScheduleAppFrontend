"""种子数据逻辑"""
from sqlalchemy import select

from app.db.models import ChatMessage, User, UserPreference
from app.db.session import async_session_factory


async def run_seed() -> bool:
    """写入种子数据，返回是否执行了写入"""
    async with async_session_factory() as session:
        result = await session.execute(select(User).limit(1))
        if result.scalar_one_or_none() is not None:
            return False

        users = [
            User(id="user_001", nickname="小明"),
            User(id="user_002", nickname="小红"),
            User(id="user_003", nickname="小刚"),
        ]
        for u in users:
            session.add(u)
        await session.flush()

        preferences = [
            UserPreference(user_id="user_001", category="schedule_habit", content="习惯早上 8 点开始学习"),
            UserPreference(user_id="user_001", category="interest", content="喜欢跑步和阅读"),
            UserPreference(user_id="user_002", category="schedule_habit", content="午休 1 小时"),
            UserPreference(user_id="user_002", category="constraint", content="周末不安排工作"),
            UserPreference(user_id="user_003", category="interest", content="健身、编程"),
        ]
        for p in preferences:
            session.add(p)

        messages = [
            ChatMessage(user_id="user_001", role="user", content="帮我安排明天上午"),
            ChatMessage(user_id="user_001", role="assistant", content="好的，明天上午可以安排...", spirit_type="light"),
        ]
        for m in messages:
            session.add(m)

        await session.commit()
        return True
