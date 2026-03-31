from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models import User, UserProfile, UserSchedule
from app.schemas import (
    ScheduleCreateRequest,
    ScheduleUpdateRequest,
    ScheduleResponse,
)

router = APIRouter(tags=["schedules"])

VALID_DAYS = {
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
}


def _validate_schedule(day: str, start_time, end_time):
    if day not in VALID_DAYS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="day는 monday~sunday 중 하나여야 합니다.",
        )

    if start_time >= end_time:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="start_time은 end_time보다 빨라야 합니다.",
        )


def _get_user_or_404(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다.",
        )
    return user


def _get_schedule_or_404(db: Session, schedule_id: int):
    schedule = db.query(UserSchedule).filter(UserSchedule.id == schedule_id).first()
    if not schedule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="일정을 찾을 수 없습니다.",
        )
    return schedule


def _serialize_schedule_row(row) -> ScheduleResponse:
    return ScheduleResponse(
        id=row.id,
        user_id=row.user_id,
        user_name=row.user_name,
        day=row.day,
        start_time=row.start_time,
        end_time=row.end_time,
        name=row.name,
        location=row.location,
        description=row.description,
        created_at=row.created_at,
        updated_at=row.updated_at,
    )


@router.post(
    "/schedules",
    response_model=ScheduleResponse,
    status_code=status.HTTP_201_CREATED,
    summary="일정 추가",
    description="현재 로그인한 사용자의 시간표 일정을 추가합니다.",
)
def create_schedule(
    request: ScheduleCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    day = request.day.strip().lower()
    _validate_schedule(day, request.start_time, request.end_time)

    new_schedule = UserSchedule(
        user_id=current_user.id,
        day=day,
        start_time=request.start_time,
        end_time=request.end_time,
        name=request.name.strip(),
        location=request.location.strip() if request.location else None,
        description=request.description.strip() if request.description else None,
    )

    db.add(new_schedule)
    db.commit()
    db.refresh(new_schedule)

    user_name = None
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if profile and profile.display_name:
        user_name = profile.display_name
    else:
        user_name = current_user.username

    return ScheduleResponse(
        id=new_schedule.id,
        user_id=new_schedule.user_id,
        user_name=user_name,
        day=new_schedule.day,
        start_time=new_schedule.start_time,
        end_time=new_schedule.end_time,
        name=new_schedule.name,
        location=new_schedule.location,
        description=new_schedule.description,
        created_at=new_schedule.created_at,
        updated_at=new_schedule.updated_at,
    )


@router.get(
    "/schedules/me",
    response_model=list[ScheduleResponse],
    summary="내 일정 목록 조회",
    description="현재 로그인한 사용자의 시간표 일정을 조회합니다.",
)
def list_my_schedules(
    day: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user_name = None
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if profile and profile.display_name:
        user_name = profile.display_name
    else:
        user_name = current_user.username

    query = db.query(UserSchedule).filter(UserSchedule.user_id == current_user.id)

    if day:
        day = day.strip().lower()
        if day not in VALID_DAYS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="day는 monday~sunday 중 하나여야 합니다.",
            )
        query = query.filter(UserSchedule.day == day)

    schedules = query.order_by(UserSchedule.day.asc(), UserSchedule.start_time.asc()).all()

    return [
        ScheduleResponse(
            id=s.id,
            user_id=s.user_id,
            user_name=user_name,
            day=s.day,
            start_time=s.start_time,
            end_time=s.end_time,
            name=s.name,
            location=s.location,
            description=s.description,
            created_at=s.created_at,
            updated_at=s.updated_at,
        )
        for s in schedules
    ]


@router.get(
    "/schedules/me/{schedule_id}",
    response_model=ScheduleResponse,
    summary="내 일정 상세 조회",
    description="현재 로그인한 사용자의 특정 일정을 조회합니다.",
)
def get_my_schedule_detail(
    schedule_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    schedule = (
        db.query(UserSchedule)
        .filter(
            UserSchedule.id == schedule_id,
            UserSchedule.user_id == current_user.id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="일정을 찾을 수 없습니다.",
        )

    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    user_name = profile.display_name if profile and profile.display_name else current_user.username

    return ScheduleResponse(
        id=schedule.id,
        user_id=schedule.user_id,
        user_name=user_name,
        day=schedule.day,
        start_time=schedule.start_time,
        end_time=schedule.end_time,
        name=schedule.name,
        location=schedule.location,
        description=schedule.description,
        created_at=schedule.created_at,
        updated_at=schedule.updated_at,
    )


@router.patch(
    "/schedules/{schedule_id}",
    response_model=ScheduleResponse,
    summary="일정 수정",
    description="현재 로그인한 사용자의 특정 일정을 수정합니다.",
)
def update_schedule(
    schedule_id: int,
    request: ScheduleUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    schedule = (
        db.query(UserSchedule)
        .filter(
            UserSchedule.id == schedule_id,
            UserSchedule.user_id == current_user.id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="일정을 찾을 수 없습니다.",
        )

    new_day = request.day.strip().lower() if request.day is not None else schedule.day
    new_start_time = request.start_time if request.start_time is not None else schedule.start_time
    new_end_time = request.end_time if request.end_time is not None else schedule.end_time

    _validate_schedule(new_day, new_start_time, new_end_time)

    schedule.day = new_day
    schedule.start_time = new_start_time
    schedule.end_time = new_end_time

    if request.name is not None:
        schedule.name = request.name.strip()
    if request.location is not None:
        schedule.location = request.location.strip() if request.location else None
    if request.description is not None:
        schedule.description = request.description.strip() if request.description else None

    db.commit()
    db.refresh(schedule)

    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    user_name = profile.display_name if profile and profile.display_name else current_user.username

    return ScheduleResponse(
        id=schedule.id,
        user_id=schedule.user_id,
        user_name=user_name,
        day=schedule.day,
        start_time=schedule.start_time,
        end_time=schedule.end_time,
        name=schedule.name,
        location=schedule.location,
        description=schedule.description,
        created_at=schedule.created_at,
        updated_at=schedule.updated_at,
    )


@router.delete(
    "/schedules/{schedule_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="일정 삭제",
    description="현재 로그인한 사용자의 특정 일정을 삭제합니다.",
)
def delete_schedule(
    schedule_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    schedule = (
        db.query(UserSchedule)
        .filter(
            UserSchedule.id == schedule_id,
            UserSchedule.user_id == current_user.id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="일정을 찾을 수 없습니다.",
        )

    db.delete(schedule)
    db.commit()


@router.get(
    "/users/{user_id}/schedules",
    response_model=list[ScheduleResponse],
    summary="특정 유저 일정 목록 조회",
    description="특정 사용자의 시간표 일정을 조회합니다.",
)
def list_user_schedules(
    user_id: int,
    day: str | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_user = _get_user_or_404(db, user_id)

    profile = db.query(UserProfile).filter(UserProfile.user_id == target_user.id).first()
    user_name = profile.display_name if profile and profile.display_name else target_user.username

    query = db.query(UserSchedule).filter(UserSchedule.user_id == user_id)

    if day:
        day = day.strip().lower()
        if day not in VALID_DAYS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="day는 monday~sunday 중 하나여야 합니다.",
            )
        query = query.filter(UserSchedule.day == day)

    schedules = query.order_by(UserSchedule.day.asc(), UserSchedule.start_time.asc()).all()

    return [
        ScheduleResponse(
            id=s.id,
            user_id=s.user_id,
            user_name=user_name,
            day=s.day,
            start_time=s.start_time,
            end_time=s.end_time,
            name=s.name,
            location=s.location,
            description=s.description,
            created_at=s.created_at,
            updated_at=s.updated_at,
        )
        for s in schedules
    ]


@router.get(
    "/users/{user_id}/schedules/{schedule_id}",
    response_model=ScheduleResponse,
    summary="특정 유저 일정 상세 조회",
    description="특정 사용자의 일정 하나를 조회합니다.",
)
def get_user_schedule_detail(
    user_id: int,
    schedule_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    target_user = _get_user_or_404(db, user_id)

    schedule = (
        db.query(UserSchedule)
        .filter(
            UserSchedule.id == schedule_id,
            UserSchedule.user_id == user_id,
        )
        .first()
    )

    if not schedule:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="일정을 찾을 수 없습니다.",
        )

    profile = db.query(UserProfile).filter(UserProfile.user_id == target_user.id).first()
    user_name = profile.display_name if profile and profile.display_name else target_user.username

    return ScheduleResponse(
        id=schedule.id,
        user_id=schedule.user_id,
        user_name=user_name,
        day=schedule.day,
        start_time=schedule.start_time,
        end_time=schedule.end_time,
        name=schedule.name,
        location=schedule.location,
        description=schedule.description,
        created_at=schedule.created_at,
        updated_at=schedule.updated_at,
    )