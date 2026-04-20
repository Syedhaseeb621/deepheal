import requests
import json
import time

def test_chat():
    url = "http://127.0.0.1:8000/chat"
    
    test_messages = [
        {"user_id": "123", "message": "I feel very stressed and overwhelmed"},
        {"user_id": "123", "message": "I am so lonely today"},
        {"user_id": "123", "message": "I blame myself for what happened"},
        {"user_id": "456", "message": "I don't know why I am so angry"}
    ]
    
    print("--- Starting DeepHeal Backend Tests ---")
    
    for msg in test_messages:
        try:
            print(f"\nSending: '{msg['message']}' (User: {msg['user_id']})")
            response = requests.post(url, json=msg)
            
            if response.status_code == 200:
                data = response.json()
                print(f"Detected Emotion: {data['emotion']}")
                print(f"Response: {data['response']['text']}")
                print(f"Suggestion: {data['response']['suggestion']}")
                print(f"Reflection: {data['response']['reflection']}")
            else:
                print(f"Error: Received status code {response.status_code}")
                print(response.text)
                
        except Exception as e:
            print(f"Request failed: {e}")
            print("Is the server running? Run 'py -m app.main' first.")
            break

if __name__ == "__main__":
    test_chat()
