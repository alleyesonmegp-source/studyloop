## Inspiration

Most study apps reward minutes, streaks, and completed checklists. But time
spent is not the same as learning. We wanted every learner to finish a session
knowing two things: what became stronger, and why a specific topic should come
back next.

## What it does

StudyLoop turns a learner's own notes and exam date into an adaptive daily
mission. The learner adds a subject, topic, deadline, and study material. The
app creates a focused micro-lesson, starts a distraction-free session, and
finishes with three grounded retrieval questions.

Missed questions enter a local rescue queue and return at the start of the next
mission until they are answered correctly. Every answer updates mastery, exam
readiness, and the next review interval. StudyLoop explains why a topic is
recommended instead of hiding the decision behind an AI score.

The optional Coach AI uses GPT-5.6 Sol to turn a selected topic and optional
notes into a structured micro-lesson and exactly three age-appropriate
questions with explanations. A curated offline fallback keeps the complete
product testable without a backend or API key.

## How we built it

- Flutter and Material 3 for the Android experience
- SharedPreferences for privacy-first local progress and history
- A deterministic adaptive-priority and spaced-review engine
- FastAPI as the secure server-side boundary
- OpenAI Responses API with GPT-5.6 Sol
- Pydantic Structured Outputs for reliable lesson and quiz contracts
- Codex for product architecture, implementation, debugging, tests, and
  submission preparation

GPT-5.6 is used where generation creates real value: grounded learning packs.
Scheduling remains deterministic, visible, and explainable. The API key never
ships in the APK, OpenAI responses use `store=False`, and the backend rejects
obvious contact information in learner notes.

Codex supported the project throughout Build Week: designing the adaptive
engine, creating the Flutter UI and state model, implementing the FastAPI
backend, adding minor-safety controls, fixing small-screen overflow, producing
tests, translating the competition build, and preparing the public repository.

## Challenges we ran into

The main design challenge was deciding what AI should *not* control. A fully
generative tutor can feel unpredictable, while a purely deterministic app
cannot create useful practice from arbitrary notes. We separated those
responsibilities: GPT-5.6 creates schema-validated learning content, while a
transparent engine decides what returns and when.

We also needed the project to remain useful when a backend is unavailable.
StudyLoop therefore includes a complete offline demo, while clearly labeling
whether a learning pack came from GPT-5.6 or the fallback.

## Accomplishments that we're proud of

- A complete focus → recall → adapt → repeat learning loop
- Exam goals grounded in the learner's own material and deadline
- A persistent mistake-rescue queue
- Explainable topic ordering and readiness evidence
- Persistent mastery, accuracy, XP, streak, and session history
- Structured GPT-5.6 learning packs
- A privacy-aware backend boundary and useful offline fallback
- A small-screen-tested English Android experience

## What we learned

Adaptive learning feels more trustworthy when the product exposes its
reasoning. Structured Outputs also allow a generative model to behave like a
reliable application component instead of an unbounded chat box. Most
importantly, retrieval evidence is more useful than merely counting time spent.

## What's next for StudyLoop

Next steps include teacher-created curricula, encrypted local profiles, richer
accessibility, multilingual learning packs, source citations, consent flows,
and evaluation of question quality with educators.

With appropriate school and guardian consent, future integrations with school
platforms and learning management systems could securely import assignments,
deadlines, subjects, and grades. StudyLoop could then build daily missions
automatically and focus practice on the areas where each learner needs the most
support.
