# Devpost submission draft

## Project name

StudyLoop — Focus. Recall. Adapt. Repeat.

## Track

Education

## One-line pitch

StudyLoop turns a student's own notes and exam date into an explainable daily
learning mission; GPT-5.6 creates grounded retrieval practice and mistakes
decide what returns next.

## Inspiration

Study tools often reward minutes, streaks, and completed checklists. But time
spent is not the same as learning. We wanted a student to finish every session
knowing two things: what became stronger, and why a specific topic should come
back next.

## What it does

The learner pastes the material for an upcoming exam. StudyLoop turns it into a
micro-mission, starts a focused session, and finishes with three grounded
retrieval questions. Missed questions enter a local rescue queue and return at
the start of the next mission. Every answer changes mastery, readiness, and the
next review interval. The app explains every recommendation rather than hiding
it behind an AI score.

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
- Exam goals built from the learner's own material and deadline.
- A persistent mistake-rescue queue with visible readiness evidence.
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
flows, and evaluation of question quality with educators. Future integrations
with school platforms and learning management systems could securely import
assignments, deadlines, subjects, and grades—with appropriate school and
guardian consent—so StudyLoop can build daily missions automatically and focus
practice on the areas where each learner needs the most support.

## Three-minute demo script

### 0:00–0:20 — Problem

"Most study apps count minutes. StudyLoop measures what becomes stable and
explains what to do next."

### 0:20–0:55 — Notes to mission

Open "Obiettivo verifica", load the complete photosynthesis demo, and save it.
Show the deadline, grounded notes, and readiness estimate.

### 0:55–1:35 — Complete a loop

Start the mission, point to the micro-lesson derived from the notes, and skip
the timer with "I finished". Answer one question incorrectly. Show the
educational feedback.

### 1:35–2:00 — Visible adaptation

Show changed readiness, XP, and the rescue counter. Start again and show that
the missed question returns first. Emphasize that the behavior is deterministic
and explainable.

### 2:00–2:30 — GPT-5.6 Coach

Enter a topic and learner difficulty. Generate a micro-lesson. Show the
"GPT-5.6 Sol" status, structured lesson, and three generated questions.

### 2:30–2:48 — Safety and architecture

Show the privacy card and architecture diagram: key on backend, `store=False`,
PII rejection, strict schema, offline fallback.

### 2:48–3:00 — Close

"StudyLoop uses AI to create the right practice, but transparent learning
evidence decides what comes next."

## Testing instructions for judges

1. Install the provided Android APK.
2. Complete onboarding; choose any name and confirm the age/guardian disclosure.
3. Tap "Create exam goal", then "Load complete demo example" and save.
4. Start the mission and use "I finished" to reach the quiz immediately.
5. Miss at least one answer, inspect Progress, and start the mission again to
   see the rescue queue.
6. Open Coach AI. If the hosted backend is unavailable, the app clearly labels
   and uses its offline fallback; the rest of the product remains functional.
7. To use your own GPT-5.6 key, put it in `backend/.env`, start FastAPI, then
   open "GPT-5.6 connection" in the app and enter the backend URL. Never enter
   an API key on the phone.
