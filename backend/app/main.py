from fastapi import FastAPI,APIRouter
from app.database import test_db_connection
from .schemas import DBCheckResponse
from fastapi.middleware.cors import CORSMiddleware
from app.routers.auth import router as auth_router

app = FastAPI()

app.add_middleware( 
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인 허용
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메소드 허용
    allow_headers=["*"],  # 모든 헤더 허용
)

app.include_router(auth_router)


@app.get("/")
def root():
    return {"message": "FastAPI server is running"}


@app.get(
    "/db-check",
    response_model=DBCheckResponse,
    summary="Database connection check",
    description="Check if the MySQL database connection is working properly."
)
def db_check():
    try:
        result = test_db_connection()
        return DBCheckResponse(
            success=True,
            message="MySQL connection successful",
            result=result
        )

    except Exception as e:
        return DBCheckResponse(
            success=False,
            message="MySQL connection failed",
            error=str(e)
        )