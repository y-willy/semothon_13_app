import os
from openai import OpenAI
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app import schemas, models
import json

router = APIRouter(
    prefix="/api/ai",
    tags=["AI Features"]
)

# 환경 변수에서 기본 API 키를 읽어와 초기 설정
api_key = "0FSeuXcueB9auGDkB5pn4tuz4h9LbRGU"
client = None

if api_key:
    # 제공된 Mindlogic API 연동 방식 (OpenAI SDK 호환)
    client = OpenAI(
        api_key=api_key,
        base_url="https://factchat-cloud.mindlogic.ai/v1/gateway"
    )

MODEL_NAME = "claude-sonnet-4-6"

# ---------------------------------------------------------------------------
# 과목별 질문 목록 (하드코딩)
# ---------------------------------------------------------------------------
SUBJECT_QUESTIONS: dict = {
    "디자인적 사고": {
        "questions": [
            {
                "index": 1,
                "text": "최근 흥미로웠던 개발 주제가 있으신가요? (중복 가능)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["사회 문제 해결", "재미있는 서비스", "기술적으로 도전적인", "창업 아이디어", "생활 편의 서비스"]
            },
            {
                "index": 2,
                "text": "어떤 개발 경험이 있으신가요? (중복 가능)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["디자인 (UI/UX)", "게임 개발", "웹 프로그래밍", "앱 프로그래밍", "AI / 머신러닝", "시스템 프로그래밍", "데이터 분석"]
            },
            {
                "index": 3,
                "text": "이건 정말 창의적이다라고 생각되시는 아이디어가 있나요?",
                "type": "free_text",
                "multiple": None,
                "options": None
            },
            {
                "index": 4,
                "text": "관심있는 문제 영역이 있나요?",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["교육", "환경", "건강", "교통", "커뮤니티", "게임 / 엔터테인먼트", "생산성"]
            },
            {
                "index": 5,
                "text": "프로젝트 결과물이 어디까지 나오면 좋겠나요?",
                "type": "multiple_choice",
                "multiple": False,
                "options": ["아이디어 기획 중심", "간단한 프로토타입", "핵심 기능 구현", "대부분 기능 구현", "실제 배포 가능 수준"]
            },
        ],
        "tip": "디자인적 사고는 개발보다 디자인적 사고를 거쳐 도출하는 아이디어가 더 중요합니다. 기술 구현보다 문제 정의와 창의성에 초점을 맞춰 주제를 추천하세요."
    },
    "세계와 시민": {
        "questions": [
            {
                "index": 1,
                "text": "우리 조가 다뤄봤으면 하는 사회문제 분야는 무엇인가요? (1~2개 선택)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["환경/생태", "인권/복지", "생활/안전", "교육/문화", "기술/과학", "기타"]
            },
            {
                "index": 2,
                "text": "최근 일상생활에서 불편을 느끼거나 문제라고 생각했던 경험이 있다면 무엇인가요?",
                "type": "free_text",
                "multiple": None,
                "options": None
            },
            {
                "index": 3,
                "text": "해결하는 사회문제 혹은 해결을 위한 노력이 어떤 범위에서 이루어졌으면 좋겠나요?",
                "type": "multiple_choice",
                "multiple": False,
                "options": ["캠퍼스", "지역사회", "대한민국/국가 및 글로벌"]
            },
            {
                "index": 4,
                "text": "이번 활동에서 대변하거나 돕고싶은 구체적 대상은 누구인가요?",
                "type": "free_text",
                "multiple": None,
                "options": None
            },
            {
                "index": 5,
                "text": "사회문제를 조사하고 해결하는 과정에서 특히 도전해보고 싶은 해결 방식은 무엇인가요? (1~2개 선택)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["숏폼 영상 제작", "오프라인 캠페인", "카드뉴스 제작", "SNS 운영", "제도 제안 및 문제 상황 신고 활동", "기타"]
            },
        ],
        "tip": "세계와 시민 과목은 사회문제 해결에 초점을 맞춥니다. 팀원들이 관심 갖는 사회 이슈와 표현 방식을 중심으로, 실제로 실행 가능한 캠페인·콘텐츠 형태의 주제를 추천하세요."
    },
    "데이터분석캡스톤디자인": {
        "questions": [
            {
                "index": 1,
                "text": "가장 흥미를 느끼는 산업/도메인은 무엇인가요? (최대 3개 선택)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["스마트시티 / 교통", "헬스케어 / 스포츠", "엔터테인먼트 / 미디어", "금융 / 경제", "소셜 / 커뮤니티", "기타"]
            },
            {
                "index": 2,
                "text": "이번 프로젝트에서 메인으로 다뤄보고 싶은 데이터의 종류는 무엇인가요? (1~2개 선택)",
                "type": "multiple_choice",
                "multiple": True,
                "options": ["이미지 / 영상 데이터 (컴퓨터 비전)", "텍스트 데이터 (자연어 처리, LLM 활용)", "정형 데이터 (CSV, DB 형태)", "시계열 데이터"]
            },
            {
                "index": 3,
                "text": "우리 팀의 최종 결과물은 어떤 형태였으면 좋겠나요?",
                "type": "multiple_choice",
                "multiple": False,
                "options": ["실제 사용 가능한 웹/앱 서비스", "가벼운 환경에서 동작하는 온디바이스 AI 어플리케이션", "데이터 시각화 중심의 대시보드 (Streamlit 등)", "특정 모델의 성능 개선 및 분석 결과 중심의 리포트/논문"]
            },
            {
                "index": 4,
                "text": "이번 학기에 꼭 활용해 보거나 역량을 키우고 싶은 기술 스택이 있나요? (자유 기재)",
                "type": "free_text",
                "multiple": None,
                "options": None
            },
            {
                "index": 5,
                "text": "최근 일상이나 전공 공부 중 '이거 데이터로 해결하거나 자동화할 수 있지 않을까?'라고 생각했던 불편함이나 호기심을 자유롭게 적어주세요.",
                "type": "free_text",
                "multiple": None,
                "options": None
            },
        ],
        "tip": "데이터분석 캡스톤디자인은 데이터 기반의 분석·모델링·서비스 구현에 초점을 맞춥니다. 팀원들의 관심 도메인, 희망 데이터 유형, 결과물 형태를 최우선으로 고려하여 실현 가능한 주제를 추천하세요."
    },
}

@router.post("/ice-breaking", response_model=schemas.IceBreakingResponse)
def analyze_ice_breaking(request: schemas.IceBreakingRequest, db: Session = Depends(get_db)):
    """
    [Phase 1] 아이스브레이킹 & 성향 분석 API
    각 팀원들의 답변을 종합하여 LLM이 팀 전체 성향 및 팀원간 시너지를 분석합니다.
    """
    if not client:
         raise HTTPException(status_code=500, detail="API Key is not configured")
    
    # 로직 구체화 예정
    
    return schemas.IceBreakingResponse(
        success=True,
        message="분석 성공",
        analysis_report="가상의 분석 레포트입니다."
    )

@router.get("/topics/questions", response_model=schemas.SubjectQuestionsResponse)
def get_topic_questions(subject: str = Query(..., description="과목명. 예: 디자인적 사고")):
    """
    [Phase 2 - 사전 요청] 과목별 주제 선정 질문 목록 조회
    프론트엔드가 질문을 렌더링하기 위해 먼저 호출합니다.
    """
    subject_data = SUBJECT_QUESTIONS.get(subject)
    if not subject_data:
        raise HTTPException(
            status_code=404,
            detail=f"'{subject}'은(는) 지원하지 않는 과목입니다. 지원 과목: {list(SUBJECT_QUESTIONS.keys())}"
        )

    questions = [
        schemas.QuestionItem(
            index=q["index"],
            text=q["text"],
            type=q["type"],
            multiple=q.get("multiple"),
            options=q.get("options"),
        )
        for q in subject_data["questions"]
    ]

    return schemas.SubjectQuestionsResponse(
        subject=subject,
        questions=questions,
        tip=subject_data.get("tip")
    )


@router.post("/topics", response_model=schemas.TopicRecommendResponse)
def recommend_topics(request: schemas.TopicRecommendRequest, db: Session = Depends(get_db)):
    """
    [Phase 2] 주제 추천 API
    팀원 전체의 답변을 종합하여 LLM이 해당 과목에 맞는 프로젝트 주제 3개를 추천합니다.
    """
    if not client:
        raise HTTPException(status_code=500, detail="API Key is not configured")

    # 1. 과목 유효성 확인
    subject_data = SUBJECT_QUESTIONS.get(request.subject)
    if not subject_data:
        raise HTTPException(
            status_code=400,
            detail=f"지원하지 않는 과목입니다. 지원 과목: {list(SUBJECT_QUESTIONS.keys())}"
        )

    # 2. 룸 존재 여부 확인
    room = db.query(models.Room).filter(models.Room.id == request.room_id).first()
    if not room:
        raise HTTPException(status_code=404, detail="해당 룸을 찾을 수 없습니다.")

    # 3. 룸 멤버 프로필 조회 (user_id → username 매핑)
    members = (
        db.query(models.User, models.UserProfile)
        .join(models.RoomMember, models.RoomMember.user_id == models.User.id)
        .outerjoin(models.UserProfile, models.UserProfile.user_id == models.User.id)
        .filter(models.RoomMember.room_id == request.room_id)
        .all()
    )
    user_map = {user.id: user.username for user, _ in members}

    # 4. 질문 목록 텍스트화
    questions = subject_data["questions"]
    questions_text = "\n".join(
        [f"Q{q['index']}. {q['text']}" for q in questions]
    )

    # 5. 팀원별 답변 집계
    all_answers_text = ""
    for member_ans in request.member_answers:
        username = user_map.get(member_ans.user_id, f"user_{member_ans.user_id}")
        all_answers_text += f"\n[{username}의 답변]\n"
        for idx, answer in enumerate(member_ans.answers):
            q_text = questions[idx]["text"] if idx < len(questions) else f"질문 {idx+1}"
            all_answers_text += f"  Q{idx+1}. {q_text}\n  → {answer}\n"

    # 6. 프롬프트 구성
    tip_text = subject_data.get("tip", "")

    system_prompt = (
        f"너는 '{request.subject}' 과목의 팀 프로젝트 주제 추천 전문가 AI야.\n"
        f"[과목 핵심 방향] {tip_text}\n\n"
        "팀원들의 답변을 종합 분석하여, 팀 전체에 가장 잘 맞는 프로젝트 주제 3개를 추천해줘.\n"
        "반드시 아래 JSON 형식만 출력하고, 설명·마크다운 코드블록 없이 순수 JSON 배열만 반환해야 해.\n\n"
        "출력 형식:\n"
        "[\n"
        "  {\"topic_name\": \"주제명\", \"reason\": \"이 팀에 맞는 추천 이유\", \"expected_effect\": \"기대 효과\"},\n"
        "  ...\n"
        "]"
    )

    user_prompt = (
        f"[과목] {request.subject}\n\n"
        f"[질문 목록]\n{questions_text}\n\n"
        f"[팀원별 답변]\n{all_answers_text}\n\n"
        "위 내용을 바탕으로 이 팀에게 최적화된 프로젝트 주제 3개를 JSON 배열로 추천해줘."
    )

    # 7. LLM 호출
    try:
        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        )
        raw_text = response.choices[0].message.content.strip()
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI API 호출 오류: {str(e)}")

    # 8. JSON 파싱
    try:
        topics_data = json.loads(raw_text)
        topics = [
            schemas.RecommendedTopic(
                topic_name=t["topic_name"],
                reason=t["reason"],
                expected_effect=t["expected_effect"],
            )
            for t in topics_data
        ]
    except (json.JSONDecodeError, KeyError):
        raise HTTPException(
            status_code=500,
            detail=f"AI 응답 파싱 실패. 원본 응답: {raw_text[:300]}"
        )

    return schemas.TopicRecommendResponse(success=True, topics=topics)


@router.post("/tasks", response_model=schemas.TaskDistributeResponse)
def distribute_tasks(request: schemas.TaskDistributeRequest, db: Session = Depends(get_db)):
    """
    [Phase 3] 프로젝트 To-Do 생성 및 분배 API
    """
    if not client:
         raise HTTPException(status_code=500, detail="API Key is not configured")
         
    return schemas.TaskDistributeResponse(
        success=True,
        tasks=[]
    )

@router.post("/chat", response_model=schemas.ChatMessageResponse)
def chat_with_bot(request: schemas.ChatMessageRequest, db: Session = Depends(get_db)):
    """
    [Phase 4] 팀 통합 데이터베이스 AI Q&A API
    해당 룸(방)에 존재하는 과거 채팅 트래킹 포함
    """
    if not client:
         raise HTTPException(status_code=500, detail="API Key is not configured")
         
    # 사용자 메시지 DB 저장 (발신: USER)
    new_message = models.ChatMessage(room_id=request.room_id, message=request.message, sender_type="USER")
    db.add(new_message)
    db.commit()
    db.refresh(new_message)

    # 이전 내역 불러와서 컨텍스트로 전달
    history = db.query(models.ChatMessage).filter(models.ChatMessage.room_id == request.room_id).order_by(models.ChatMessage.created_at.asc()).all()
    
    messages = [
        {"role": "system", "content": "너는 세모톤 프로젝트의 다정하고 유머러스한 AI 어시스턴트야. 과거 대화 내용과 상황을 바탕으로 답변해줘."}
    ]
    
    for h in history:
        # ROLE 변환 (USER -> user, AI -> assistant)
        role = "user" if h.sender_type == "USER" else "assistant"
        messages.append({"role": role, "content": h.message})
    
    try:
        # Mindlogic API (OpenAI SDK 호환) 호출
        response = client.chat.completions.create(
            model=MODEL_NAME, # 사용 모델: claude-sonnet-4-6
            messages=messages,
        )
        answer_text = response.choices[0].message.content
    except Exception as e:
        answer_text = f"AI API 응답 과정에서 오류가 발생했습니다: {str(e)}"
    
    # AI 응답을 DB에 저장
    ai_reply = models.ChatMessage(room_id=request.room_id, message=answer_text, sender_type="AI")
    db.add(ai_reply)
    db.commit()

    return schemas.ChatMessageResponse(
        success=True,
        reply=answer_text
    )
