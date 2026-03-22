import os
from urllib.parse import quote_plus
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

load_dotenv()

def get_env(key: str):
    value = os.getenv(key)
    if value is None:
        raise ValueError(f"{key} 환경변수가 설정되지 않았습니다.")
    return value

user = get_env("DB_USERNAME")
raw_password = get_env("DB_PASSWORD")
password = quote_plus(raw_password)

host = get_env("DB_HOST")
port = get_env("DB_PORT")
db_name = get_env("DB_NAME")

DATABASE_URL = f"mysql+pymysql://{user}:{password}@{host}:{port}/{db_name}?charset=utf8mb4"

engine = create_engine(
    DATABASE_URL,
    pool_recycle=3600,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
try:
    with engine.connect() as conn:
        print("DB 연결 성공!")
except Exception as e:
    print("DB 연결 실패:", e)