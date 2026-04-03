from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Todo, Room, User
from app import schemas

router = APIRouter(prefix="/todos", tags=["todos"])

@router.post(
    "",
    response_model=schemas.TodoResponse,
    summary="Todo 등록"
)
def create_todo(
    request: schemas.TodoCreateRequest,
    db: Session = Depends(get_db),
):
    room = db.query(Room).filter(Room.id == request.room_id).first()
    if room is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 room이 존재하지 않습니다."
        )

    creator = db.query(User).filter(User.id == request.creator_user_id).first()
    if creator is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="creator_user_id에 해당하는 사용자가 존재하지 않습니다."
        )

    if request.assignee_user_id is not None:
        assignee = db.query(User).filter(User.id == request.assignee_user_id).first()
        if assignee is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="assignee_user_id에 해당하는 사용자가 존재하지 않습니다."
            )

    new_todo = Todo(
        room_id=request.room_id,
        creator_user_id=request.creator_user_id,
        assignee_user_id=request.assignee_user_id,
        title=request.title,
        description=request.description,
        status=request.status,
        success_flag=request.success_flag,
        progress_percent=request.progress_percent,
        priority=request.priority,
        category=request.category,
        tag=request.tag,
        start_date=request.start_date,
        due_date=request.due_date,
        completed_at=request.completed_at,
        estimated_minutes=request.estimated_minutes,
        actual_minutes=request.actual_minutes,
        visibility=request.visibility,
        source_type=request.source_type,
        ai_suggested=request.ai_suggested,
        sort_order=request.sort_order,
        archived=request.archived,
        deleted=request.deleted,
    )

    db.add(new_todo)
    db.commit()
    db.refresh(new_todo)

    return new_todo


@router.get(
    "/users/{user_id}",
    response_model=schemas.TodoListResponse,
    summary="개인 Todo 조회"
)
def get_user_todos(
    user_id: int,
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 사용자가 존재하지 않습니다."
        )

    todos = (
        db.query(Todo)
        .filter(
            Todo.assignee_user_id == user_id,
            (Todo.deleted == False) | (Todo.deleted.is_(None))
        )
        .order_by(Todo.created_at.desc())
        .all()
    )

    return schemas.TodoListResponse(
        success=True,
        todos=todos,
    )

@router.get(
    "/rooms/{room_id}",
    response_model=schemas.TodoListResponse,
    summary="팀 Todo 목록 조회"
)
def get_room_todos(
    room_id: int,
    db: Session = Depends(get_db),
):
    room = db.query(Room).filter(Room.id == room_id).first()
    if room is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 room이 존재하지 않습니다."
        )

    todos = (
        db.query(Todo)
        .filter(
            Todo.room_id == room_id,
            (Todo.deleted == False) | (Todo.deleted.is_(None))
        )
        .order_by(Todo.created_at.desc())
        .all()
    )

    return schemas.TodoListResponse(
        success=True,
        todos=todos,
    )


@router.put(
    "/{todo_id}",
    response_model=schemas.TodoResponse,
    summary="Todo 수정"
)
def update_todo(
    todo_id: int,
    request: schemas.TodoUpdateRequest,
    db: Session = Depends(get_db),
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if todo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 todo가 존재하지 않습니다."
        )

    if request.assignee_user_id is not None:
        assignee = db.query(User).filter(User.id == request.assignee_user_id).first()
        if assignee is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="assignee_user_id에 해당하는 사용자가 존재하지 않습니다."
            )
        todo.assignee_user_id = request.assignee_user_id

    if request.title is not None:
        todo.title = request.title

    if request.description is not None:
        todo.description = request.description

    if request.status is not None:
        todo.status = request.status

    if request.success_flag is not None:
        todo.success_flag = request.success_flag

    if request.progress_percent is not None:
        if request.progress_percent < 0 or request.progress_percent > 100:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="progress_percent는 0 이상 100 이하여야 합니다."
            )
        todo.progress_percent = request.progress_percent

    if request.priority is not None:
        todo.priority = request.priority

    if request.category is not None:
        todo.category = request.category

    if request.tag is not None:
        todo.tag = request.tag

    if request.start_date is not None:
        todo.start_date = request.start_date

    if request.due_date is not None:
        todo.due_date = request.due_date

    if request.completed_at is not None:
        todo.completed_at = request.completed_at

    if request.estimated_minutes is not None:
        todo.estimated_minutes = request.estimated_minutes

    if request.actual_minutes is not None:
        todo.actual_minutes = request.actual_minutes

    if request.visibility is not None:
        todo.visibility = request.visibility

    if request.source_type is not None:
        todo.source_type = request.source_type

    if request.ai_suggested is not None:
        todo.ai_suggested = request.ai_suggested

    if request.sort_order is not None:
        todo.sort_order = request.sort_order

    if request.archived is not None:
        todo.archived = request.archived

    if request.deleted is not None:
        todo.deleted = request.deleted

    db.commit()
    db.refresh(todo)

    return todo

@router.delete(
    "/{todo_id}",
    response_model=schemas.SimpleSuccessResponse,
    summary="Todo 삭제(소프트 삭제)"
)
def delete_todo(
    todo_id: int,
    db: Session = Depends(get_db),
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if todo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 todo가 존재하지 않습니다."
        )

    todo.deleted = True
    db.commit()

    return schemas.SimpleSuccessResponse(
        success=True,
        message="Todo가 삭제되었습니다."
    )
@router.patch(
    "/{todo_id}/status",
    response_model=schemas.TodoResponse,
    summary="Todo 상태 변경"
)
def update_todo_status(
    todo_id: int,
    request: schemas.TodoStatusUpdateRequest,
    db: Session = Depends(get_db),
):
    todo = db.query(Todo).filter(Todo.id == todo_id).first()
    if todo is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="해당 todo가 존재하지 않습니다."
        )

    todo.status = request.status

    if request.progress_percent is not None:
        if request.progress_percent < 0 or request.progress_percent > 100:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="progress_percent는 0 이상 100 이하여야 합니다."
            )
        todo.progress_percent = request.progress_percent

    if request.success_flag is not None:
        todo.success_flag = request.success_flag

    if request.status == "DONE":
        if todo.completed_at is None:
            from datetime import datetime
            todo.completed_at = datetime.now()
        if todo.progress_percent is None:
            todo.progress_percent = 100
    else:
        # 필요하면 DONE이 아닐 때 completed_at 유지/초기화 정책 선택 가능
        pass

    db.commit()
    db.refresh(todo)

    return todo