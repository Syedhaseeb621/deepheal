import json
import os
from typing import Dict

class CBTService:
    def __init__(self, data_path: str):
        self.data_path = data_path
        self.responses = self._load_responses()

    def _load_responses(self) -> Dict:
        if not os.path.exists(self.data_path):
            # Fallback to hardcoded defaults if file is missing
            return {
                "default": {
                    "response": "I'm here to listen.",
                    "suggestion": "Stay here for a moment.",
                    "reflection": "What's on your mind?"
                }
            }
        
        with open(self.data_path, "r") as f:
            return json.load(f)

    def get_structured_response(self, emotion: str) -> Dict:
        return self.responses.get(emotion, self.responses["default"])
