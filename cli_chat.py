import sys
import os

# Add backend to path so we can import app modules directly without starting the server
backend_path = os.path.join(os.path.dirname(__file__), "backend")
sys.path.append(backend_path)

from app.services.chat_service import ChatService
from app.routes.chat_routes import DATA_PATH

def main():
    # Initialize the ChatService using the existing CBT data
    chat_service = ChatService(DATA_PATH)
    
    print("\n" + "="*50)
    print("🧠 Welcome to DeepHeal CLI Chatbot 🧠")
    print("Type 'quit' or 'exit' to stop the chat.")
    print("="*50 + "\n")
    
    user_id = "cli_user"
    
    while True:
        try:
            user_input = input("You: ")
            if user_input.strip().lower() in ['quit', 'exit', 'q']:
                print("\nDeepHeal: Take care! Remember, I'm always here if you need to talk.")
                break
            
            if not user_input.strip():
                continue
                
            # Process message through the chat service
            response = chat_service.process_message(user_id, user_input)
            
            print(f"\nDeepHeal [Detected Emotion: {response.emotion.upper()}]")
            print(f"💬 {response.response.text}")
            print(f"💡 Suggestion: {response.response.suggestion}")
            print(f"🤔 Reflection: {response.response.reflection}\n")
            
        except KeyboardInterrupt:
            print("\nDeepHeal: Goodbye! Take care.")
            break
        except Exception as e:
            print(f"\n[Error]: {e}")

if __name__ == "__main__":
    main()
