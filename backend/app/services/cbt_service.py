import json
import os
import re
from typing import List, Dict

class CBTService:
    def __init__(self, data_path: str):
        self.data_path = data_path
        self.responses = self._load_responses()

    def _load_responses(self) -> List[Dict]:
        if not os.path.exists(self.data_path):
            return [
                {
                    "keywords": ["default"],
                    "emotion": "default",
                    "response": "I'm here to listen.",
                    "suggestion": "Stay here for a moment.",
                    "reflection": "What's on your mind?"
                }
            ]
        
        with open(self.data_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def get_structured_response(self, emotion: str, user_message: str = "") -> Dict:
        message_lower = user_message.lower()
        
        # 1. First attempt: search for keyword match in user message
        for entry in self.responses:
            for kw in entry.get("keywords", []):
                # Use regex to match word boundaries
                if re.search(r'\b' + re.escape(kw.lower()) + r'\b', message_lower):
                    return {
                        "response": entry["response"],
                        "suggestion": entry["suggestion"],
                        "reflection": entry["reflection"]
                    }
                    
        # 2. Second attempt: match by emotion
        for entry in self.responses:
            if entry.get("emotion") == emotion:
                return {
                    "response": entry["response"],
                    "suggestion": entry["suggestion"],
                    "reflection": entry["reflection"]
                }
                
        # 3. Third attempt: fall back to default emotion
        for entry in self.responses:
            if entry.get("emotion") == "default":
                return {
                    "response": entry["response"],
                    "suggestion": entry["suggestion"],
                    "reflection": entry["reflection"]
                }
                
        # Hard fallback
        return {
            "response": "I'm here to listen.",
            "suggestion": "Stay here for a moment.",
            "reflection": "What's on your mind?"
        }

