from fastapi import APIRouter, Depends
from app.models.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService
import os

router = APIRouter()

# Dependency for ChatService
# We initialize it with the path to the responses JSON
DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "cbt_responses.json")
chat_service = ChatService(DATA_PATH)

@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Mental Health Chatbot Endpoint.
    Detects emotion and returns structured CBT responses.
    """
    response = chat_service.process_message(request.user_id, request.message)
    return response
