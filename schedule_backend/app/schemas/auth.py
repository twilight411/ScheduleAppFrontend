"""
鉴权 Schemas — 注册/登录/Token/密码重置

登录标识使用 account（用户名），不再强制邮箱格式。
email 字段仅作旧客户端兼容，新客户端请只传 account。
"""
from pydantic import BaseModel, Field, field_validator, model_validator


def _normalize_account(value: str) -> str:
    return (value or "").strip().lower()


class RegisterRequest(BaseModel):
    """注册请求"""
    account: str = Field(..., min_length=1, max_length=64, description="用户名/账号")
    password: str = Field(..., min_length=6, max_length=128)
    name: str = Field(..., min_length=1, max_length=100)

    @field_validator("account", "name")
    @classmethod
    def _strip_fields(cls, v: str) -> str:
        v = (v or "").strip()
        if not v:
            raise ValueError("不能为纯空白")
        return v

    @field_validator("account")
    @classmethod
    def _normalize_register_account(cls, v: str) -> str:
        return _normalize_account(v)


class LoginRequest(BaseModel):
    """登录请求 — account 优先，email 仅兼容旧版"""
    account: str | None = Field(None, min_length=1, max_length=64)
    email: str | None = Field(None, min_length=1, max_length=255)
    password: str = Field(..., min_length=1, max_length=128)

    @model_validator(mode="after")
    def _require_account(self) -> "LoginRequest":
        if not (self.account or self.email):
            raise ValueError("缺少账号")
        return self

    def resolved_account(self) -> str:
        raw = self.account or self.email or ""
        return _normalize_account(raw)


class TokenResponse(BaseModel):
    """Token 响应 — 登录/注册/刷新成功后返回"""
    access_token: str
    refresh_token: str
    expires_in: int
    token_type: str = "bearer"
    user_id: str | None = None
    account: str | None = None
    nickname: str | None = None


class RefreshRequest(BaseModel):
    """刷新 Token 请求"""
    refresh_token: str = Field(..., min_length=10)


class ForgotPasswordRequest(BaseModel):
    """忘记密码（账号找回，沿用 account 字段名）"""
    account: str = Field(..., min_length=1, max_length=64)

    @field_validator("account")
    @classmethod
    def _normalize_forgot_account(cls, v: str) -> str:
        return _normalize_account(v.strip())


class ResetPasswordRequest(BaseModel):
    """重置密码"""
    token: str = Field(..., min_length=10)
    new_password: str = Field(..., min_length=6, max_length=128)


class LogoutRequest(BaseModel):
    """登出请求"""
    refresh_token: str = Field(..., min_length=10)
