# DeepHeal - AI-Powered Mental Health Companion 🧠✨

DeepHeal is a production-ready, CBT-based mental health chatbot designed to provide emotional support, reflection exercises, and therapeutic suggestions. It uses a clean, modular architecture combining a high-end Flutter frontend with a robust FastAPI backend.

---

## 🚀 Project Overview

DeepHeal detects user emotions through real-time text analysis and provides structured therapeutic responses based on Cognitive Behavioral Therapy (CBT) principles.

*   **Frontend**: Professional Flutter application with a focus on premium UI/UX.
*   **Backend**: Python FastAPI system with custom Emotion Detection and CBT Engines.
*   **Intelligence**: Trained on industry-standard datasets like **GoEmotions**, **CounselChat**, and **MentalChat16K**.

---

## 📁 Repository Structure

```text
deepheal/
├── lib/               # Flutter Frontend (Dart)
│   ├── core/          # App constants, themes, and providers
│   ├── features/      # Chat, Dashboard, and History modules
│   └── data/          # App models and mock data
├── backend/           # FastAPI Backend (Python)
│   ├── app/           # Main logic, routes, and services
│   ├── data/          # CBT responses and training documentation
│   └── Dockerfile     # Production deployment configuration
└── README.md          # Project Documentation
```

---

## 🛠️ Installation & Setup

### 1. Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable)
*   [Python 3.12+](https://www.python.org/downloads/)
*   Git

### 2. Backend Setup
Navigate to the backend directory and set up the environment:
```bash
cd backend
python -m venv venv
# Windows
.\venv\Scripts\activate
# macOS/Linux
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Frontend Setup
From the project root:
```bash
flutter pub get
```

---

## 🏃 Running the Project

### Phase 1: Start the Backend (Must be first)
```bash
cd backend
python -m app.main
```
The server will start at `http://127.0.0.1:8000`. You can visit `http://127.0.0.1:8000/docs` for the interactive API documentation.

### Phase 2: Start the Frontend
1.  Check `lib/core/constants/api_constants.dart` and ensure the `baseUrl` matches your local IP or `127.0.0.1`.
2.  Launch your emulator or connect a device.
3.  Run:
```bash
flutter run
```

---

## 🧬 Core Architecture

### Emotion Engine
Categorizes user input into 7 key emotional states:
*   `Stress`, `Anxiety`, `Sadness`, `Anger`, `Fatigue`, `Loneliness`, `Guilt`

### CBT Engine
Maps detected emotions to structured therapeutic responses:
*   **Main Response**: Empathetic acknowledgment of the emotion.
*   **CBT Suggestion**: Actionable exercise (e.g., 4-7-8 breathing).
*   **Reflection Question**: Cognitive inquiry to encourage deeper insight.

---

## ☁️ Deployment

The project includes a **Dockerfile** in the `backend/` folder. To deploy to production (e.g., Render, AWS):
1.  Connect your GitHub repo.
2.  Set the **Root Directory** to `backend`.
3.  Choose **Docker** as the runtime.

---

## ❤️ Credits & Data
DeepHeal's logic is built upon recognized academic research. Detailed source documentation and dataset links can be found in `backend/app/data/training_sources.md`.
