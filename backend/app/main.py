from fastapi import FastAPI,APIRouter
from app.database import test_db_connection
from .schemas import DBCheckResponse

app = FastAPI()

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