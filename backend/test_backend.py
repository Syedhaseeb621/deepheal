import requests
import json

def run_20_scenarios():
    url = "http://127.0.0.1:8000/chat"
    
    test_cases = [
        {"msg": "I am feeling stressed about my work and deadlines", "expected": "Work Stress"},
        {"msg": "I am worried about my exams and grades", "expected": "Exam/Study Stress"},
        {"msg": "I feel overwhelmed and everything is too much", "expected": "General Overwhelm"},
        {"msg": "I had a panic attack today and my heart is racing", "expected": "Panic / Acute Anxiety"},
        {"msg": "I worry about my future and what if I fail", "expected": "Future Anxiety"},
        {"msg": "I get anxious around crowds of people", "expected": "Social Anxiety"},
        {"msg": "I am dealing with the loss and grief of a friend who passed away", "expected": "Grief / Loss"},
        {"msg": "I am going through a painful breakup and feel heartbroken", "expected": "Breakup / Heartbreak"},
        {"msg": "I feel sad, depressed, and unhappy today", "expected": "General Low Mood"},
        {"msg": "Everything feels hopeless and I want to give up", "expected": "Hopelessness"},
        {"msg": "I am so angry at my brother, it is unfair", "expected": "Anger at Someone"},
        {"msg": "I am angry at myself for screwing up", "expected": "Self-Anger"},
        {"msg": "I am physically tired and sleep-deprived", "expected": "Physical Fatigue"},
        {"msg": "I feel mentally burnt out and drained", "expected": "Mental Burnout"},
        {"msg": "I feel so lonely and left out from the group", "expected": "Lonely in a Crowd"},
        {"msg": "I have no one to talk to and feel isolated", "expected": "Lonely / Isolation"},
        {"msg": "I feel guilty and blame myself for the accident", "expected": "Guilt over Action"},
        {"msg": "I feel unworthy and full of shame", "expected": "Shame / Unworthiness"},
        {"msg": "Hello! Can you help me start my mental health journey?", "expected": "Welcome / Intro"},
        {"msg": "Thanks, that was very good info", "expected": "General / Hard to classify"}
    ]
    
    print("================================================================================")
    print("                     DEEPHEAL 20 SCENARIOS FALLBACK TEST                        ")
    print("================================================================================")
    
    success_count = 0
    for idx, tc in enumerate(test_cases, 1):
        payload = {"user_id": f"test_user_{idx}", "message": tc["msg"]}
        try:
            response = requests.post(url, json=payload)
            if response.status_code == 200:
                data = response.json()
                print(f"\n[Test {idx}/20] Category: {tc['expected']}")
                print(f"User Input: \"{tc['msg']}\"")
                print(f"Detected Emotion: {data['emotion'].upper()}")
                print(f"CBT Response: {data['response']['text']}")
                print(f"Suggestion: {data['response']['suggestion']}")
                print(f"Reflection: {data['response']['reflection']}")
                success_count += 1
            else:
                print(f"\n[Test {idx}/20] Failed with status code {response.status_code}: {response.text}")
        except Exception as e:
            print(f"\n[Test {idx}/20] Connection error: {e}")
            print("Please ensure the FastAPI server is running ('python -m app.main' in backend directory).")
            break
            
    print("\n================================================================================")
    print(f"Test Summary: {success_count}/{len(test_cases)} scenarios executed successfully.")
    print("================================================================================")

if __name__ == "__main__":
    run_20_scenarios()
