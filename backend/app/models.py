# app/models.py
from sqlalchemy import Column, String, DateTime, func, ForeignKey, Text, Enum, BigInteger, Integer, Time
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
    hobby = Column(String(255), nullable=True)
    role = Column(String(255), nullable=True)
    user = relationship("User", back_populates="profile")


class File(Base):
    __tablename__ = "files"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    room_id = Column(BigInteger, ForeignKey("rooms.id", ondelete="CASCADE"), nullable=False)
    uploaded_by = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    task_id = Column(BigInteger, ForeignKey("tasks.id", ondelete="SET NULL"), nullable=True)

    original_name = Column(String(255), nullable=False)
    stored_name = Column(String(255), nullable=False)
    object_key = Column(String(500), nullable=False)
    file_url = Column(String(500), nullable=False)
    mime_type = Column(String(100), nullable=True)
    file_size = Column(BigInteger, nullable=True)

    created_at = Column(DateTime, nullable=False, server_default=func.now())

from sqlalchemy import Column, BigInteger, String, DateTime, ForeignKey, Integer
from sqlalchemy.sql import func
from app.database import Base


class Room(Base):
    __tablename__ = "rooms"

    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    host_user_id = Column(BigInteger, ForeignKey("users.id"), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(String(500), nullable=True)
    invite_code = Column(String(20), unique=True, nullable=False)
    max_members = Column(Integer, default=10)
    status = Column(String(50), default="active")
    current_stage = Column(String(50), default="waiting")
    created_at = Column(DateTime, server_default=func.now())

class RoomMember(Base):
    __tablename__ = "room_members"

    id = Column(BigInteger, primary_key=True, autoincrement=True)

    room_id = Column(BigInteger,ForeignKey("rooms.id", ondelete="CASCADE"),nullable=False)
    user_id = Column(BigInteger,ForeignKey("users.id", ondelete="CASCADE"),nullable=False)
    role_in_room = Column(String(20), default="member")
    join_status = Column(String(20), default="joined")
    joined_at = Column(DateTime, server_default=func.now())

class Task(Base):
    __tablename__ = "tasks"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    room_id = Column(BigInteger, ForeignKey("rooms.id", ondelete="CASCADE"), nullable=False)
    assigned_user_id = Column(BigInteger, ForeignKey("users.id"), nullable=True)
    title = Column(String(255), nullable=False)
    description = Column(String(500), nullable=True)
    status = Column(String(50), default="pending")
    progress_percent = Column(Integer, default=0)
    priority = Column(String(20), default="normal")
    due_date = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now())


class UserSchedule(Base):
    __tablename__ = "user_schedules"

    id = Column(BigInteger, primary_key=True, autoincrement=True, index=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    day = Column(String(20), nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)

    name = Column(String(255), nullable=False)
    location = Column(String(255), nullable=True)
    description = Column(String(500), nullable=True)

    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime,
        nullable=False,
        server_default=func.now(),
        onupdate=func.now(),
    )