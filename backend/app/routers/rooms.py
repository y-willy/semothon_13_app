import random
import string

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session, aliased

from app.database import get_db
from app.dependencies import get_current_user
from app.models import Room, RoomMember, User, UserProfile
from app.schemas import (
    RoomCreateRequest,
    RoomCreateResponse,
    RoomDetailResponse,
    RoomListItemResponse,
    RoomMemberItem,
    RoomUserAddRequest,
    RoomUserAddResponse,
)

router = APIRouter(prefix="/rooms", tags=["rooms"])


def generate_invite_code(length: int = 6) -> str:
    chars = string.ascii_uppercase + string.digits
    return "".join(random.choices(chars, k=length))


def get_unique_invite_code(db: Session) -> str:
    while True:
        code = generate_invite_code()
        exists = db.query(Room).filter(Room.invite_code == code).first()
        if not exists:
            return code


def _get_room_or_404(db: Session, room_id: int) -> Room:
    room = db.query(Room).filter(Room.id == room_id).first()
    if not room:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="룸을 찾을 수 없습니다.",
        )
    return room


def _get_room_member(db: Session, room_id: int, user_id: int):
    return (
        db.query(RoomMember)
        .filter(
            RoomMember.room_id == room_id,
            RoomMember.user_id == user_id,
        )
        .first()
    )


def _check_room_member(db: Session, room_id: int, user_id: int):
    member = _get_room_member(db, room_id, user_id)
    if not member:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="해당 룸의 멤버만 접근할 수 있습니다.",
        )
    return member


def _check_room_host(db: Session, room_id: int, user_id: int):
    member = _get_room_member(db, room_id, user_id)
    if not member or member.role_in_room != "HOST":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="해당 룸의 HOST만 수행할 수 있습니다.",
        )
    return member


@router.post(
    "",
    response_model=RoomCreateResponse,
    status_code=status.HTTP_201_CREATED,
    summary="룸 추가하기",
    description="새 룸을 생성하고 생성한 사용자를 HOST로 room_members에 자동 추가합니다.",
)
def create_room(
    request: RoomCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    invite_code = get_unique_invite_code(db)

    new_room = Room(
        host_user_id=current_user.id,
        title=request.title.strip(),
        description=request.description.strip() if request.description else None,
        invite_code=invite_code,
        max_members=request.max_members,
        status="WAITING",
        current_stage="WAITING",
    )
    db.add(new_room)
    db.flush()

    host_member = RoomMember(
        room_id=new_room.id,
        user_id=current_user.id,
        role_in_room="HOST",
        join_status="JOINED",
    )
    db.add(host_member)

    db.commit()
    db.refresh(new_room)

    return new_room


@router.get(
    "/{room_id}",
    response_model=RoomDetailResponse,
    summary="룸 세부 정보 가져오기",
    description="룸 기본 정보와 룸 멤버 목록을 반환합니다.",
)
def get_room_detail(
    room_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    room = _get_room_or_404(db, room_id)
    _check_room_member(db, room_id, current_user.id)

    host_row = (
        db.query(
            User.id.label("user_id"),
            func.coalesce(UserProfile.display_name, User.username).label("host_name"),
        )
        .outerjoin(UserProfile, UserProfile.user_id == User.id)
        .filter(User.id == room.host_user_id)
        .first()
    )

    host_name = host_row.host_name if host_row else ""

    member_rows = (
        db.query(
            RoomMember.user_id.label("user_id"),
            User.username.label("username"),
            UserProfile.display_name.label("display_name"),
            RoomMember.role_in_room.label("role_in_room"),
            RoomMember.join_status.label("join_status"),
            RoomMember.joined_at.label("joined_at"),
        )
        .join(User, RoomMember.user_id == User.id)
        .outerjoin(UserProfile, UserProfile.user_id == User.id)
        .filter(RoomMember.room_id == room_id)
        .order_by(RoomMember.joined_at.asc())
        .all()
    )

    members = [
        RoomMemberItem(
            user_id=row.user_id,
            username=row.username,
            display_name=row.display_name,
            role_in_room=row.role_in_room,
            join_status=row.join_status,
            joined_at=row.joined_at,
        )
        for row in member_rows
    ]

    return RoomDetailResponse(
        id=room.id,
        host_user_id=room.host_user_id,
        host_name=host_name,
        title=room.title,
        description=room.description,
        invite_code=room.invite_code,
        max_members=room.max_members,
        status=room.status,
        current_stage=room.current_stage,
        created_at=room.created_at,
        members=members,
    )


@router.post(
    "/{room_id}/users",
    response_model=RoomUserAddResponse,
    status_code=status.HTTP_201_CREATED,
    summary="룸 사용자 추가하기",
    description="특정 룸에 사용자를 추가합니다. 현재는 HOST만 추가할 수 있게 했습니다.",
)
def add_user_to_room(
    room_id: int,
    request: RoomUserAddRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    room = _get_room_or_404(db, room_id)
    _check_room_host(db, room_id, current_user.id)

    target_user = db.query(User).filter(User.id == request.user_id).first()
    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="추가할 사용자를 찾을 수 없습니다.",
        )

    existing_member = _get_room_member(db, room_id, request.user_id)
    if existing_member:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미 룸에 속한 사용자입니다.",
        )

    current_member_count = (
        db.query(func.count(RoomMember.id))
        .filter(RoomMember.room_id == room_id)
        .scalar()
    )

    if current_member_count >= room.max_members:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="룸 최대 인원을 초과할 수 없습니다.",
        )

    role_in_room = request.role_in_room.upper().strip()
    if role_in_room not in {"HOST", "MEMBER"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="role_in_room은 HOST 또는 MEMBER만 가능합니다.",
        )

    new_member = RoomMember(
        room_id=room_id,
        user_id=request.user_id,
        role_in_room=role_in_room,
        join_status="JOINED",
    )
    db.add(new_member)
    db.commit()
    db.refresh(new_member)

    return RoomUserAddResponse(
        room_id=new_member.room_id,
        user_id=new_member.user_id,
        role_in_room=new_member.role_in_room,
        join_status=new_member.join_status,
        joined_at=new_member.joined_at,
    )


@router.get(
    "",
    response_model=list[RoomListItemResponse],
    summary="룸 리스트 가져오기",
    description="현재 로그인한 사용자가 속한 룸 목록을 반환합니다.",
)
def list_rooms(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    MyMembership = aliased(RoomMember)
    AllMembers = aliased(RoomMember)
    HostUser = aliased(User)
    HostProfile = aliased(UserProfile)
    rows = (
        db.query(
            Room.id.label("id"),
            Room.host_user_id.label("host_user_id"),
            func.coalesce(HostProfile.display_name, HostUser.username).label("host_name"),
            Room.title.label("title"),
            Room.description.label("description"),
            Room.invite_code.label("invite_code"),
            Room.max_members.label("max_members"),
            Room.status.label("status"),
            Room.current_stage.label("current_stage"),
            Room.created_at.label("created_at"),
            func.count(AllMembers.id).label("member_count"),
        )
        .join(MyMembership, MyMembership.room_id == Room.id)
        .join(HostUser, HostUser.id == Room.host_user_id)
        .outerjoin(HostProfile, HostProfile.user_id == HostUser.id)
        .join(AllMembers, AllMembers.room_id == Room.id)
        .filter(MyMembership.user_id == current_user.id)
        .group_by(
            Room.id,
            Room.host_user_id,
            HostUser.username,
            HostProfile.display_name,
            Room.title,
            Room.description,
            Room.invite_code,
            Room.max_members,
            Room.status,
            Room.current_stage,
            Room.created_at,
        )
        .order_by(Room.created_at.desc())
        .all()
    )

    return [
        RoomListItemResponse(
            id=row.id,
            host_user_id=row.host_user_id,
            host_name=row.host_name,
            title=row.title,
            description=row.description,
            invite_code=row.invite_code,
            max_members=row.max_members,
            member_count=row.member_count,
            status=row.status,
            current_stage=row.current_stage,
            created_at=row.created_at,
        )
        for row in rows
    ]