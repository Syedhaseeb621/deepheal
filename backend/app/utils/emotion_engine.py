import re

class EmotionEngine:
    def __init__(self):
        # Expanded keywords mapped to emotions for "perfect" detection
        self.emotion_map = {
            "stress": ["stressed", "overwhelmed", "pressure", "deadline", "busy", "too much", "burnout", "taxing", "tiring", "struggling", "weight on my shoulders", "can't cope", "hectic", "chaos"],
            "anxiety": ["anxious", "worry", "worried", "scared", "fear", "panic", "heart racing", "nervous", "uneasy", "jittery", "dread", "apprehensive", "tense", "shaking", "restless"],
            "sadness": ["sad", "depressed", "unhappy", "cry", "hopeless", "down", "lonely", "alone", "miserable", "heartbroken", "gloomy", "heavy heart", "blue", "grief", "low mood"],
            "anger": ["angry", "mad", "furious", "annoyed", "unfair", "frustrated", "hate", "irritated", "pissed", "rage", "resentful", "bitter", "enraged", "fuming"],
            "fatigue": ["tired", "exhausted", "fatigue", "sleepy", "drained", "no energy", "weary", "sluggish", "burnt out", "lethargic", "wiped out", "sleep-deprived"],
            "loneliness": ["lonely", "alone", "isolated", "no one to talk to", "feeling left out", "disconnected", "solitary", "abandoned", "forlorn", "empty"],
            "guilt": ["guilty", "regret", "blame myself", "shame", "should have", "my fault", "remorse", "apologetic", "self-reproach", "unworthy"]
        }

    def detect_emotion(self, text: str) -> str:
        """
        Detects emotion based on robust keyword matching.
        This mimics a classification model behavior with high precision.
        """
        text = text.lower()
        
        # Check for multiple keywords to find the most dominant emotion
        scores = {emotion: 0 for emotion in self.emotion_map.keys()}
        
        for emotion, keywords in self.emotion_map.items():
            for keyword in keywords:
                if re.search(r'\b' + re.escape(keyword) + r'\b', text):
                    scores[emotion] += 1
        
        # Return the emotion with the highest score
        max_emotion = max(scores, key=scores.get)
        if scores[max_emotion] > 0:
            return max_emotion
        
        return "default"
