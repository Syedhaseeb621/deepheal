from typing import Dict, List

class MemoryService:
    def __init__(self, limit: int = 5):
        # user_id -> List of messages
        self.storage: Dict[str, List[str]] = {}
        self.limit = limit

    def add_message(self, user_id: str, message: str):
        if user_id not in self.storage:
            self.storage[user_id] = []
        
        self.storage[user_id].append(message)
        
        # Keep only the last 5 messages
        if len(self.storage[user_id]) > self.limit:
            self.storage[user_id] = self.storage[user_id][-self.limit:]

    def get_history(self, user_id: str) -> List[str]:
        return self.storage.get(user_id, [])
