import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.database import Base, get_db

# Isolated in-memory SQLite database for unit tests
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(autouse=True)
def setup_db():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_liveness_probe():
    """Verify /healthz returns 200 and status healthy."""
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_readiness_probe(monkeypatch):
    """Verify /readyz reports readiness when database connection is live."""
    monkeypatch.setattr("app.main.check_db_health", lambda: True)
    response = client.get("/readyz")
    assert response.status_code == 200
    assert response.json() == {"status": "ready", "database": "connected"}


def test_readiness_probe_failure(monkeypatch):
    """Verify /readyz returns 503 when database is unreachable."""
    monkeypatch.setattr("app.main.check_db_health", lambda: False)
    response = client.get("/readyz")
    assert response.status_code == 503
    assert response.json()["detail"] == {"status": "unready", "database": "disconnected"}


def test_create_number_success():
    """Test creating a valid integer entry."""
    payload = {"value": 42}
    response = client.post("/api/numbers", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["value"] == 42
    assert "id" in data
    assert "created_at" in data


def test_create_number_invalid_type():
    """Test integer validation rejects non-integer strings."""
    payload = {"value": "invalid-string"}
    response = client.post("/api/numbers", json=payload)
    assert response.status_code == 422  # Unprocessable Entity


def test_list_numbers_empty():
    """Test listing numbers when database is empty."""
    response = client.get("/api/numbers")
    assert response.status_code == 200
    assert response.json() == []


def test_ui_root_endpoint():
    """Test GET / returns HTML content."""
    response = client.get("/")
    assert response.status_code == 200
    assert "text/html" in response.headers["content-type"]
    assert "Integer Collector" in response.text

