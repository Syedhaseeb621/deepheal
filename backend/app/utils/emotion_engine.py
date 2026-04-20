import re

class EmotionEngine:
    def __init__(self):
        # Keywords mapped to emotions
        self.emotion_map = {
            "stress": ["stressed", "overwhelmed", "pressure", "deadline", "busy", "too much"],
            "anxiety": ["anxious", "worry", "worried", "scared", "fear", "panic", "heart racing"],
            "sadness": ["sad", "depressed", "unhappy", "cry", "hopeless", "down", "lonely", "alone"],
            "anger": ["angry", "mad", "furious", "annoyed", "unfair", "frustrated", "hate"],
            "fatigue": ["tired", "exhausted", "fatigue", "sleepy", "drained", "no energy"],
            "loneliness": ["lonely", "alone", "isolated", "no one to talk to", "feeling left out"],
            "guilt": ["guilty", "regret", "blame myself", "shame", "should have", "my fault"]
        }

    def detect_emotion(self, text: str) -> str:
        """
        Detects emotion based on keyword matching.
        This mimics a classification model behavior.
        """
        text = text.lower()
        
        for emotion, keywords in self.emotion_map.items():
            for keyword in keywords:
                if re.search(r'\b' + re.escape(keyword) + r'\b', text):
                    return emotion
        
        return "default"
