# app/models.py
from sqlalchemy import Column, String, DateTime, func, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.mysql import BIGINT

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(BIGINT(unsigned=True), primary_key=True, autoincrement=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
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


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(BIGINT(unsigned=True), primary_key=True, autoincrement=True, index=True)
    user_id = Column(
        BIGINT(unsigned=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        unique=True,
    )

    display_name = Column(String(50), nullable=False)
    mbti = Column(String(10), nullable=True)
    major = Column(String(100), nullable=True)
    bio = Column(Text, nullable=True)
    personality_summary = Column(Text, nullable=True)
    profile_image_url = Column(String(255), nullable=True)

    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="profile")
