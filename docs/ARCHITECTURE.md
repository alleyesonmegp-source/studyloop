# StudyLoop architecture and judging notes

## Product thesis

Most study timers optimize for time spent. StudyLoop optimizes for the next
useful learning action. It closes the loop between attention, retrieval
practice, evidence, and scheduling.

## Adaptive engine

The engine intentionally remains deterministic and inspectable:

```text
priority =
  mastery gap × 60
  + accuracy gap × 25
  + overdue hours × 0.8
```

Correct answers increase mastery and schedule a longer review interval.
Incorrect answers slightly reduce mastery and schedule a near-term retry. This
is not presented as a psychometric diagnosis; it is a transparent learning aid.

## GPT-5.6 role

GPT-5.6 Sol is used where generative intelligence adds real value: converting a
learner's chosen topic and optional notes into a concise micro-lesson and three
retrieval questions. Pydantic Structured Outputs enforce the app contract:

- exactly three questions;
- exactly four options per question;
- one correct index;
- an explanation for feedback;
- the same supported subject ID;
- an explicit source marker.

The deterministic engine remains responsible for scheduling and progress. This
division prevents an opaque model response from controlling the learner's
history.

## Privacy and safety boundaries

- No OpenAI key in mobile code.
- Local progress storage.
- `store=False` for Responses API calls.
- Input lengths are bounded.
- Obvious email addresses and phone numbers are rejected.
- The prompt is restricted to age-appropriate educational content.
- Onboarding requires a 14+/guardian acknowledgement and explains AI fallibility.
- Offline fallback keeps testing possible without sending data.

## Judging criteria alignment

### Technological implementation

Flutter app, persisted adaptive state, real focus-to-recall loop, FastAPI
boundary, GPT-5.6 Responses API, schema-constrained outputs, automated tests.

### Design

One-handed mobile navigation, small-screen-safe scrolling, explicit status for
live AI versus offline mode, and feedback that frames mistakes as useful data.

### Potential impact

Students gain a concrete next action instead of a generic dashboard. Families
and educators can discuss learning progress without equating time with mastery.

### Quality of idea

StudyLoop combines deterministic explainability with generative personalization.
AI creates content; transparent evidence decides what returns next.
