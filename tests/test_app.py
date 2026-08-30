import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, close_all_sessions
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db

SQLALCHEMY_DATABASE_URL = "sqlite:///./test_app.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base.metadata.create_all(bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_and_clean_db():
    Base.metadata.create_all(bind=engine)
    close_all_sessions()
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM numbers;"))
    yield
    close_all_sessions()
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM numbers;"))


def test_liveness_probe():
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_readiness_probe(monkeypatch):
    monkeypatch.setattr("app.main.check_db_health", lambda: True)
    response = client.get("/readyz")
    assert response.status_code == 200
    assert response.json() == {"status": "ready", "database": "connected"}


def test_readiness_probe_failure(monkeypatch):
    monkeypatch.setattr("app.main.check_db_health", lambda: False)
    response = client.get("/readyz")
    assert response.status_code == 503
    assert response.json()["detail"] == {
        "status": "unready",
        "database": "disconnected",
    }


def test_list_numbers_empty():
    response = client.get("/api/numbers")
    assert response.status_code == 200
    assert response.json() == []


def test_create_number_success():
    payload = {"value": 42}
    response = client.post("/api/numbers", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["value"] == 42
    assert data["id"] > 0
    assert "created_at" in data


def test_create_number_invalid_type():
    payload = {"value": "invalid-string"}
    response = client.post("/api/numbers", json=payload)
    assert response.status_code == 422


def test_ui_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "Integer Collector" in response.text
