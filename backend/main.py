import os
import re
from typing import Literal

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel, Field


class StudyPackRequest(BaseModel):
    topic: str = Field(min_length=2, max_length=120)
    notes: str = Field(default="", max_length=3000)
    grade: str = Field(min_length=2, max_length=80)
    subjectId: Literal["math", "english", "science"]


class GeneratedQuestion(BaseModel):
    id: str
    subjectId: Literal["math", "english", "science"]
    topic: str
    prompt: str
    options: list[str] = Field(min_length=4, max_length=4)
    correctIndex: int = Field(ge=0, le=3)
    explanation: str
    source: Literal["gpt-5.6-sol"]


class GeneratedStudyPack(BaseModel):
    title: str
    microLesson: str
    whyItMatters: str
    questions: list[GeneratedQuestion] = Field(min_length=3, max_length=3)


app = FastAPI(
    title="StudyLoop AI Coach",
    version="1.0.0",
    description="Privacy-first GPT-5.6 study-pack generator.",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("STUDYLOOP_ALLOWED_ORIGINS", "*").split(","),
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str | bool]:
    return {
        "status": "ok",
        "model": "gpt-5.6-sol",
        "configured": bool(os.getenv("OPENAI_API_KEY")),
    }


@app.post("/v1/study-pack", response_model=GeneratedStudyPack)
def create_study_pack(request: StudyPackRequest) -> GeneratedStudyPack:
    if not os.getenv("OPENAI_API_KEY"):
        raise HTTPException(
            status_code=503,
            detail="OPENAI_API_KEY is not configured on the server.",
        )

    personal_data_patterns = [
        r"\b[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}\b",
        r"\b(?:\+?39)?\s?(?:\d[\s.-]?){9,10}\b",
    ]
    if any(re.search(pattern, request.notes) for pattern in personal_data_patterns):
        raise HTTPException(
            status_code=400,
            detail="Remove email addresses or phone numbers from the notes.",
        )

    client = OpenAI()
    system_prompt = """
You are StudyLoop Coach, an expert learning designer for students.
Create a compact, age-appropriate retrieval-practice pack in Italian.
Use only the learner-provided topic and notes. Never request personal data.
The micro-lesson must explain one core idea in at most 90 words.
Create exactly 3 multiple-choice questions with exactly 4 plausible options.
Use clear language, one unambiguous correct answer, and a short educational
explanation. Keep the supplied subjectId unchanged on every question.
The whyItMatters field must explain the learning strategy, not praise the AI.
""".strip()
    user_prompt = (
        f"Livello: {request.grade}\n"
        f"Materia ID: {request.subjectId}\n"
        f"Argomento: {request.topic}\n"
        f"Appunti dello studente: {request.notes or 'Nessun appunto fornito'}"
    )
    response = client.responses.parse(
        model="gpt-5.6-sol",
        reasoning={"effort": "low"},
        store=False,
        input=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        text_format=GeneratedStudyPack,
    )
    pack = response.output_parsed
    if pack is None:
        raise HTTPException(
            status_code=422,
            detail="The model did not return a usable study pack.",
        )
    return pack
