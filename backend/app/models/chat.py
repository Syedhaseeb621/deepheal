from pydantic import BaseModel
from typing import Dict

class ChatRequest(BaseModel):
    user_id: str
    message: str

class ChatResponseContent(BaseModel):
    text: str
    suggestion: str
    reflection: str

class ChatResponse(BaseModel):
    emotion: str
    response: ChatResponseContent
