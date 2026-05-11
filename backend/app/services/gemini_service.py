import os
import google.generativeai as genai
from typing import Dict, Optional
from dotenv import load_dotenv

load_dotenv()

class GeminiService:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if api_key:
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    def generate_cbt_response(self, user_message: str, emotion: str) -> Optional[Dict]:
        if not self.model:
            return None

        prompt = f"""
        You are DeepHeal AI, a professional and empathetic mental health companion specialized in Cognitive Behavioral Therapy (CBT).
        The user is feeling: {emotion.upper()}.
        User message: "{user_message}"

        Your task is to provide a structured response in exactly this JSON format:
        {{
            "response": "A highly empathetic and warm acknowledgment of their feelings, using CBT principles to validate and comfort.",
            "suggestion": "A specific, actionable therapeutic exercise or technique (e.g., grounding, breathing, behavioral activation) they can do right now.",
            "reflection": "A thoughtful question designed to encourage deeper self-insight or cognitive reframing."
        }}

        Keep the tone premium, professional, and deeply supportive. Avoid generic advice; make it feel personal and therapeutic.
        Only return the JSON object.
        """

        try:
            response = self.model.generate_content(prompt)
            # Basic parsing of JSON from text
            import json
            import re
            
            # Find the JSON block in the response
            text = response.text
            json_match = re.search(r'\{.*\}', text, re.DOTALL)
            if json_match:
                return json.loads(json_match.group())
            return None
        except Exception as e:
            print(f"Gemini Error: {e}")
            return None
