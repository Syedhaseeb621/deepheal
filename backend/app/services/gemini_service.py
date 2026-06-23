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

    def generate_cbt_response(self, user_message: str, emotion: str, history: list = None) -> Optional[Dict]:
        if not self.model:
            print("Gemini Error: Model not initialized (check API key)")
            return None

        history_context = ""
        if history:
            history_context = "\nRecent conversation history:\n" + "\n".join(f"User: {msg}" for msg in history)

        prompt = f"""
        You are DeepHeal AI, a professional and empathetic mental health companion specialized in Cognitive Behavioral Therapy (CBT).
        The user is currently feeling: {emotion.upper()}.
        {history_context}
        Current User message: "{user_message}"

        Your task is to provide a structured response in exactly this JSON format:
        {{
            "response": "A highly empathetic and warm acknowledgment of their feelings, using CBT principles to validate and comfort. Incorporate context from recent conversation if relevant.",
            "suggestion": "A specific, actionable therapeutic exercise or technique (e.g., grounding, breathing, behavioral activation) they can do right now.",
            "reflection": "A thoughtful question designed to encourage deeper self-insight or cognitive reframing."
        }}

        Keep the tone premium, professional, and deeply supportive. Avoid generic advice; make it feel personal and therapeutic.
        Return ONLY the JSON object.
        """

        try:
            response = self.model.generate_content(prompt)
            if not response or not response.text:
                print("Gemini Error: Empty response from model")
                return None
                
            text = response.text
            
            # 1. Try to find JSON inside markdown blocks
            import json
            import re
            
            markdown_match = re.search(r'```(?:json)?\s*(\{.*?\})\s*```', text, re.DOTALL)
            if markdown_match:
                try:
                    return json.loads(markdown_match.group(1))
                except:
                    pass

            # 2. Fallback: Find any JSON block in the response
            json_match = re.search(r'\{.*\}', text, re.DOTALL)
            if json_match:
                try:
                    return json.loads(json_match.group())
                except Exception as e:
                    print(f"Gemini Error: Failed to parse JSON match: {e}\nRaw Text: {text}")
                    return None
            
            print(f"Gemini Error: No JSON found in response. Raw Text: {text}")
            return None
        except Exception as e:
            print(f"Gemini Error during generation: {e}")
            return None
