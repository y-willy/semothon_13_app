# app/models/user.py
from sqlalchemy import Column, String, DateTime, Enum, func
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.mysql import BIGINT

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(BIGINT(unsigned=True), primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=True, index=True)  # DDL 기준으로 맞춤
    password_hash = Column(String(255), nullable=False)
    status = Column(
        Enum("ACTIVE", "INACTIVE", "BANNED", name="user_status"),
        nullable=False,
        server_default="ACTIVE",
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    profile = relationship(
        "UserProfile",
        back_populates="user",
        uselist=False,
        cascade="all, delete-orphan",
    )
