import requests
import json

def run_tests():
    url = "http://127.0.0.1:8000/chat"
    
    # Test cases for all 7 emotions + default
    scenarios = [
        {"msg": "I have so much work, I am so stressed", "user": "Sahil"},
        {"msg": "I am worried about my exam results", "user": "Sahil"},
        {"msg": "I feel so alone, nobody likes me", "user": "Sahil"},
        {"msg": "I'm so angry at my brother, it's not fair!", "user": "Sahil"},
        {"msg": "I just want to sleep, I am so drained", "user": "Sahil"},
        {"msg": "I feel so guilty for forgetting her birthday", "user": "Sahil"},
        {"msg": "Everything is hopeless", "user": "Sahil"},
        {"msg": "Hello bot, how are you?", "user": "Sahil"}
    ]
    
    print(f"{'INPUT MESSAGE':<40} | {'EMOTION':<10} | {'BOT RESPONSE'}")
    print("-" * 100)
    
    for scenario in scenarios:
        payload = {"user_id": scenario["user"], "message": scenario["msg"]}
        try:
            response = requests.post(url, json=payload)
            if response.status_code == 200:
                data = response.json()
                print(f"{scenario['msg']:<40} | {data['emotion']:<10} | {data['response']['text'][:40]}...")
            else:
                print(f"Error for '{scenario['msg']}': {response.status_code}")
        except Exception as e:
            print(f"Failed to connect: {e}")

if __name__ == "__main__":
    run_tests()
