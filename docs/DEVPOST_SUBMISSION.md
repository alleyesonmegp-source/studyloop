# Devpost submission draft

## Project name

StudyLoop — Focus. Recall. Adapt. Repeat.

## Track

Education

## One-line pitch

StudyLoop turns every focus session into an explainable adaptive learning loop,
using GPT-5.6 to create retrieval practice and local evidence to decide what the
student should review next.

## Inspiration

Study tools often reward minutes, streaks, and completed checklists. But time
spent is not the same as learning. We wanted a student to finish every session
knowing two things: what became stronger, and why a specific topic should come
back next.

## What it does

StudyLoop creates a daily queue from mastery, answer accuracy, due time, and
memory decay. The learner starts a distraction-free focus session and finishes
with three retrieval questions. Each answer changes mastery and the next review
interval. The app explains every recommendation rather than hiding it behind an
AI score.

The Coach AI uses GPT-5.6 Sol to turn a chosen topic and optional notes into a
strictly structured micro-lesson and three age-appropriate questions. A curated
offline mode keeps the full product testable without a backend.

## How we built it

- Flutter and Material 3 for the Android experience.
- SharedPreferences for privacy-first local persistence.
- A deterministic adaptive priority and review engine.
- FastAPI for a server-side security boundary.
- OpenAI Responses API with GPT-5.6 Sol.
- Pydantic Structured Outputs for reliable lesson and quiz contracts.
- Codex for product architecture, implementation, debugging, tests, and
  documentation.

## How GPT-5.6 and Codex were used

GPT-5.6 Sol powers the Coach's structured learning packs. It receives a bounded
topic, grade level, and optional learner notes and returns a micro-lesson plus
exactly three four-option questions with explanations.

Codex was used throughout the core implementation: designing the adaptive
engine, creating the Flutter UI and state model, building the FastAPI boundary,
adding minor-safety controls, fixing small-screen overflow, generating tests,
and preparing the submission materials.

Before submission, add the `/feedback` Session ID here: **TODO**

## Challenges

The key design challenge was deciding what AI should *not* control. We kept
scheduling deterministic and explainable, and used GPT-5.6 only for the part
where generation adds value. We also designed the app to remain demonstrable
offline and kept the API key out of the APK.

## Accomplishments

- A complete focus → recall → adapt → repeat loop.
- Persistent mastery, accuracy, streak, and session history.
- Explainable topic ordering.
- Structured GPT-5.6 learning packs.
- Offline fallback and a privacy-aware server boundary.
- Small-screen-tested Android UI.

## What we learned

Adaptive learning feels more trustworthy when the app exposes its reasoning.
Structured Outputs also let the generative layer behave like a reliable product
component instead of an unbounded chat box.

## What's next

Teacher-created curricula, local encrypted profiles, richer accessibility,
multilingual learning packs, content-source citations, parent/teacher consent
flows, and evaluation of question quality with educators.

## Three-minute demo script

### 0:00–0:20 — Problem

"Most study apps count minutes. StudyLoop measures what becomes stable and
explains what to do next."

### 0:20–0:45 — Onboarding and daily plan

Show the grade, focus duration, AI disclosure, and adaptive queue. Point to the
reason under Mathematics.

### 0:45–1:20 — Complete a loop

Open Focus Mode, start/pause the real timer, then tap "I finished". Answer one
question correctly and one incorrectly. Show explanatory feedback.

### 1:20–1:45 — Adaptation

Return to the plan and show changed mastery, accuracy, history, and the reordered
queue. Emphasize that scheduling is deterministic and explainable.

### 1:45–2:25 — GPT-5.6 Coach

Enter a topic and learner difficulty. Generate a micro-lesson. Show the
"GPT-5.6 Sol" status, structured lesson, and three generated questions.

### 2:25–2:45 — Safety and architecture

Show the privacy card and architecture diagram: key on backend, `store=False`,
PII rejection, strict schema, offline fallback.

### 2:45–3:00 — Close

"StudyLoop uses AI to create the right practice, but transparent learning
evidence decides what comes next."

## Testing instructions for judges

1. Install the provided Android APK.
2. Complete onboarding; choose any name and confirm the age/guardian disclosure.
3. Start the first loop and use "I finished" to reach the quiz immediately.
4. Complete all three questions and inspect Progress.
5. Open Coach AI. If the hosted backend is unavailable, the app clearly labels
   and uses its offline fallback; the rest of the product remains functional.
