import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
from app.config import settings
from app.database import init_db
from app.routers import auth, users, packages, subscriptions, beneficiaries
from app.admin.router import router as admin_router

UPLOADS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(UPLOADS_DIR, exist_ok=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting Internet Packages API...")
    await init_db()
    yield
    print("👋 Shutting down...")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Internet Data Package Subscription System",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(packages.router)
app.include_router(subscriptions.router)
app.include_router(beneficiaries.router)
app.include_router(admin_router)


@app.get("/", tags=["Health"])
async def root():
    return {
        "status": "✅ API is running",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs"
    }


@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy"}


@app.get("/mikrotik/test", tags=["MikroTik"])
async def test_mikrotik():
    from app.services.mikrotik_service import MikroTikService
    return MikroTikService.test_connection()
