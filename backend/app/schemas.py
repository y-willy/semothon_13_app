from pydantic import BaseModel
from typing import Any, Optional

class DBCheckResponse(BaseModel):
    success: bool
    message: str
    result: Optional[Any] = None
    error: Optional[str] = None