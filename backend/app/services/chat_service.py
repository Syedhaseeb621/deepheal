from app.utils.emotion_engine import EmotionEngine
from app.services.memory_service import MemoryService
from app.services.cbt_service import CBTService
from app.services.gemini_service import GeminiService
from app.models.chat import ChatResponse, ChatResponseContent

class ChatService:
    def __init__(self, cbt_data_path: str):
        self.emotion_engine = EmotionEngine()
        self.memory_service = MemoryService()
        self.cbt_service = CBTService(cbt_data_path)
        self.gemini_service = GeminiService()

    def process_message(self, user_id: str, message: str) -> ChatResponse:
        # 1. Detect emotion
        emotion = self.emotion_engine.detect_emotion(message)
        
        # 2. Store in memory
        self.memory_service.add_message(user_id, message)
        
        # 3. Get response (Try Gemini first, fallback to CBT JSON)
        response_data = self.gemini_service.generate_cbt_response(message, emotion)
        
        if not response_data:
            response_data = self.cbt_service.get_structured_response(emotion)
        
        # 4. Format final response
        return ChatResponse(
            emotion=emotion,
            response=ChatResponseContent(
                text=response_data["response"],
                suggestion=response_data["suggestion"],
                reflection=response_data["reflection"]
            )
        )
