from fastapi.testclient import TestClient

from main import app


client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["model"] == "gpt-5.6-sol"


def test_study_pack_requires_server_key(monkeypatch) -> None:
    monkeypatch.delenv("OPENAI_API_KEY", raising=False)
    response = client.post(
        "/v1/study-pack",
        json={
            "topic": "Equivalent fractions",
            "notes": "",
            "grade": "Middle school",
            "subjectId": "math",
        },
    )
    assert response.status_code == 503
