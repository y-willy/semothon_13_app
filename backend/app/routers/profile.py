from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import Session, joinedload

from app.database import get_db
from app.models import User, UserProfile
from app.schemas import ProfileUpdate, PublicProfileResponse, MyProfileResponse
from app.dependencies import get_current_user

router = APIRouter(prefix="/profile", tags=["Profile"])


def get_user_with_profile(db: Session, user_id: int):
    return (
        db.query(User)
        .options(joinedload(User.profile))
        .filter(User.id == user_id)
        .first()
    )


def to_public_profile(user: User) -> PublicProfileResponse:
    profile = user.profile
    return PublicProfileResponse(
        id=user.id,
        username=user.username,
        display_name=profile.display_name if profile else None,
        mbti=profile.mbti if profile else None,
        major=profile.major if profile else None,
        bio=profile.bio if profile else None,
        personality_summary=profile.personality_summary if profile else None,
        profile_image_url=profile.profile_image_url if profile else None,
    )


def to_my_profile(user: User) -> MyProfileResponse:
    public_profile = to_public_profile(user)
    return MyProfileResponse(**public_profile.model_dump(), email=user.email)


@router.get(
    "/me",
    response_model=MyProfileResponse,
    summary="내 프로필 조회",
    description="현재 로그인한 사용자의 프로필 정보를 조회합니다. ACTIVE 상태의 사용자만 조회 가능합니다.",
    responses={
        200: {"description": "조회 성공"},
        401: {"description": "인증되지 않은 사용자"},
        404: {"description": "사용자를 찾을 수 없거나 비활성화된 계정"},
    },
)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user = get_user_with_profile(db, current_user.id)

    if not user or user.status != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없거나 비활성화된 계정입니다.",
        )

    return to_my_profile(user)


@router.get(
    "/{username}",
    response_model=PublicProfileResponse,
    summary="공개 프로필 조회",
    description="username으로 공개 프로필을 조회합니다. ACTIVE 상태의 사용자만 조회 가능합니다.",
    responses={
        200: {"description": "조회 성공"},
        404: {"description": "사용자를 찾을 수 없음"},
    },
)
def get_public_profile(username: str, db: Session = Depends(get_db)):
    user = (
        db.query(User)
        .options(joinedload(User.profile))
        .filter(User.username == username, User.status == "ACTIVE")
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다.",
        )

    return to_public_profile(user)


@router.patch(
    "/me",
    response_model=MyProfileResponse,
    summary="내 프로필 수정",
    description=(
        "현재 로그인한 사용자의 프로필을 수정합니다.\n\n"
        "- username, email 중복 여부를 확인합니다.\n"
        "- 공백 문자열은 허용하지 않습니다.\n"
        "- ACTIVE 상태인 본인 계정만 수정 가능합니다."
    ),
    responses={
        200: {"description": "수정 성공"},
        400: {"description": "잘못된 입력값"},
        403: {"description": "수정 권한 없음"},
        409: {"description": "중복 데이터 또는 제약조건 위반"},
        500: {"description": "서버 내부 오류"},
    },
)
def update_my_profile(
    profile_data: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    user = get_user_with_profile(db, current_user.id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다.",
        )

    if user.status != "ACTIVE":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="활성화된 사용자만 프로필을 수정할 수 있습니다.",
        )

    data = profile_data.model_dump(exclude_unset=True)

    for key, value in data.items():
        if isinstance(value, str):
            value = value.strip()
            if value == "":
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"'{key}' 필드에 빈 값을 입력할 수 없습니다.",
                )
            data[key] = value

    if "username" in data and data["username"] != user.username:
        username_exists = (
            db.query(User.id)
            .filter(User.username == data["username"], User.id != user.id)
            .first()
        )
        if username_exists:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 사용 중인 이름입니다.",
            )
        user.username = data["username"]

    if "email" in data and data["email"] != user.email:
        email_exists = (
            db.query(User.id)
            .filter(User.email == data["email"], User.id != user.id)
            .first()
        )
        if email_exists:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="이미 사용 중인 이메일입니다.",
            )
        user.email = data["email"]

    profile_fields = {
        "display_name",
        "mbti",
        "major",
        "bio",
        "personality_summary",
        "profile_image_url",
    }

    profile_payload = {k: v for k, v in data.items() if k in profile_fields}

    if "display_name" in profile_payload and profile_payload["display_name"] is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="display_name이 없습니다.",
        )

    if profile_payload:
        if user.profile is None:
            user.profile = UserProfile(
                user_id=user.id,
                display_name=profile_payload.get("display_name") or user.username,
            )

        for key, value in profile_payload.items():
            if key == "display_name" and value is None:
                continue
            setattr(user.profile, key, value)

    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="이미 존재하는 정보이거나 데이터베이스 제약 조건을 위반했습니다.",
        )
    except SQLAlchemyError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="데이터베이스 처리 중 예기치 못한 오류가 발생했습니다.",
        )

    updated_user = get_user_with_profile(db, user.id)
    return to_my_profile(updated_user)
