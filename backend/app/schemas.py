from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, ConfigDict


class DBCheckResponse(BaseModel):
    success: bool
    message: str
    result: Optional[dict] = None
    error: Optional[str] = None


class SignUpRequest(BaseModel):
    username: str = Field(
        ...,
        min_length=4,
        max_length=20,
        description="로그인에 사용할 아이디",
        examples=["aico_user01"]
    )
    email: EmailStr = Field(
        ...,
        description="사용자 이메일",
        examples=["user@example.com"]
    )
    password: str = Field(
        ...,
        min_length=8,
        max_length=100,
        description="비밀번호. 최소 8자 이상 입력해야 합니다.",
        examples=["StrongPass123!"]
    )


    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "username": "aico_user01",
                "email": "user@example.com",
                "password": "StrongPass123!",
            }
        }
    )


class LoginRequest(BaseModel):
    username: str = Field(
        ...,
        description="로그인 아이디",
        examples=["aico_user01"]
    )
    password: str = Field(
        ...,
        description="로그인 비밀번호",
        examples=["StrongPass123!"]
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "username": "aico_user01",
                "password": "StrongPass123!"
            }
        }
    )


class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class SignUpResponse(BaseModel):
    success: bool
    message: str
    user: UserResponse


class LoginResponse(BaseModel):
    success: bool
    message: str
    access_token: str = Field(..., description="JWT access token")
    token_type: str = Field(..., examples=["bearer"])
    user: UserResponse


class MeResponse(BaseModel):
    success: bool
    message: str
    user: UserResponse


class ErrorResponse(BaseModel):
    detail: str


class TokenPayload(BaseModel):
    sub: str
    exp: int