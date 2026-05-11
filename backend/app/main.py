from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi import Request
from app.routes import chat_routes
import logging
import traceback
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("deepheal-backend")

app = FastAPI(
    title="DeepHeal Backend",
    description="Mental Health Chatbot API with CBT-based logic.",
    version="1.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Error Handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unexpected error: {exc}\n{traceback.format_exc()}")
    return JSONResponse(
        status_code=500,
        content={"message": "An internal server error occurred. Please try again later."}
    )

# Include Routers
app.include_router(chat_routes.router)

@app.get("/")
async def root():
    return {"message": "DeepHeal Backend is running!"}

if __name__ == "__main__":
    import uvicorn
    # In production, use environment variables for host/port
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
