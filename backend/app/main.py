from fastapi import FastAPI
from app.database import test_db_connection

app = FastAPI()

@app.get("/")
def root():
    return {"message": "FastAPI server is running"}


@app.get("/db-check")
def db_check():
    try:
        result = test_db_connection()
        return {
            "success": True,
            "message": "MySQL connection successful",
            "result": result
        }
    except Exception as e:
        return {
            "success": False,
            "message": "MySQL connection failed",
            "error": str(e)
        }
