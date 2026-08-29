from pathlib import Path
from contextlib import asynccontextmanager
from typing import List

from fastapi import FastAPI, Depends, Form, Request, status, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.database import get_db, init_db, check_db_health, NumberEntry

BASE_DIR = Path(__file__).resolve().parent
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Auto-create tables on startup if not already created
    try:
        init_db()
    except Exception as e:
        print(f"Warning: DB initialization error during startup: {e}")
    yield


app = FastAPI(
    title="Integer Collector Service",
    version="1.0.0",
    description="A minimalist service that stores integer values into PostgreSQL",
    lifespan=lifespan,
)


class NumberCreate(BaseModel):
    value: int


class NumberResponse(BaseModel):
    id: int
    value: int
    created_at: str

    class Config:
        from_attributes = True


# HTML UI: Render home page with list of numbers
@app.get("/", response_class=HTMLResponse)
def read_root(request: Request, db: Session = Depends(get_db)):
    try:
        numbers = db.query(NumberEntry).order_by(NumberEntry.id.desc()).all()
    except Exception:
        numbers = []
    return templates.TemplateResponse(
        "index.html", {"request": request, "numbers": numbers}
    )


# HTML UI: Handle Form POST submission
@app.post("/", response_class=RedirectResponse)
def submit_number_form(value: int = Form(...), db: Session = Depends(get_db)):
    entry = NumberEntry(value=value)
    db.add(entry)
    db.commit()
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


# REST API: Create a new number entry
@app.post("/api/numbers", response_model=NumberResponse, status_code=status.HTTP_201_CREATED)
def create_number(payload: NumberCreate, db: Session = Depends(get_db)):
    entry = NumberEntry(value=payload.value)
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return {
        "id": entry.id,
        "value": entry.value,
        "created_at": entry.created_at.isoformat(),
    }


# REST API: List all number entries
@app.get("/api/numbers", response_model=List[NumberResponse])
def list_numbers(db: Session = Depends(get_db)):
    entries = db.query(NumberEntry).order_by(NumberEntry.id.desc()).all()
    return [
        {
            "id": item.id,
            "value": item.value,
            "created_at": item.created_at.isoformat(),
        }
        for item in entries
    ]


# Kubernetes Liveness Probe
@app.get("/healthz")
def liveness_check():
    return {"status": "healthy"}


# Kubernetes Readiness Probe
@app.get("/readyz")
def readiness_check():
    is_ready = check_db_health()
    if not is_ready:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={"status": "unready", "database": "disconnected"},
        )
    return {"status": "ready", "database": "connected"}

