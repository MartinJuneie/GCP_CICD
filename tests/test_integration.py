import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db

SQLALCHEMY_DATABASE_URL = "sqlite:///./test_integration.db"
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
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM numbers;"))
    yield
    with engine.begin() as conn:
        conn.execute(text("DELETE FROM numbers;"))


def test_full_crud_workflow():
    res1 = client.post("/api/numbers", json={"value": 100})
    assert res1.status_code == 201
    assert res1.json()["id"] > 0

    res2 = client.post("/", data={"value": 200}, follow_redirects=True)
    assert res2.status_code == 200
    assert "200" in res2.text

    res3 = client.get("/api/numbers")
    assert res3.status_code == 200
    items = res3.json()
    assert len(items) == 2
    values = [item["value"] for item in items]
    assert 100 in values
    assert 200 in values

    res4 = client.post("/api/numbers", json={"value": -50})
    assert res4.status_code == 201
    assert res4.json()["value"] == -50

    res5 = client.post("/api/numbers", json={"value": 0})
    assert res5.status_code == 201
    assert res5.json()["value"] == 0
