"""FastAPI 应用入口"""
from pathlib import Path

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import config
from app.db import init_db
from app.routers import admin, ai, schedules


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期：启动时初始化数据库"""
    try:
        await init_db()
    except Exception as e:
        import logging
        logging.warning("数据库初始化失败（AI 接口仍可用）: %s", e)
    yield


app = FastAPI(
    title="Schedule App API",
    description="AI 智能日程管理后端",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS：允许 Flutter 开发时 localhost / 模拟器访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 路由：挂载在 /api 下，与 Flutter baseUrl 对齐
app.include_router(ai.router, prefix="/api")
app.include_router(admin.router, prefix="/api")
app.include_router(schedules.router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "Schedule App API", "docs": "/docs"}


@app.get("/health")
async def health():
    return {"status": "ok"}


# 静态文件：后台监控页面（HTML/CSS/JS 分离，便于维护）
_static_dir = Path(__file__).resolve().parent.parent / "static"
app.mount("/admin", StaticFiles(directory=_static_dir / "admin", html=True), name="admin")
# /admin 和 /admin/ 均可访问


def run():
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=config.HOST,
        port=config.PORT,
        reload=True,
    )


if __name__ == "__main__":
    run()

