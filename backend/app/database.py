from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.config import settings

DATABASE_URL = (
    f"mysql+pymysql://{settings.db_user}:{settings.db_password}"
    f"@{settings.db_host}:{settings.db_port}/{settings.db_name}"
)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def test_db_connection():
    with engine.connect() as connection:
        result = connection.execute(text("SELECT 1 AS connected"))
        row = result.fetchone()
        return row[0]