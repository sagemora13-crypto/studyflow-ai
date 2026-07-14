## StudyFlow AI — App Plan

### Concept
An AI study companion for students in grades 6–12 that explains instead of just answering. Core promise and signature flow: **Upload → Understand → Practice → Schedule → Improve** — turn any notes/photo into an explanation, flashcards, a quiz, and a study schedule.

### Target Audience (v1)
Middle & high school students (grades 6–12). Start with three subjects: Math, Science, English. History, Spanish, chemistry, physics, and test prep come later.

### Design Direction
- Reference: Notion — clean, calm, content-first, spacious. Motivating progress cues (streaks, mastery %) kept mature, not childish.
- Palette: Study Night — background #101014, surface #1A1A22, primary #EDEBFF, accent #8B7CFF, text #ECECF2. Dark-first, indigo accent. Hard constraint: no unrelated accent hues.
- Catalog seed: Clean.

### Navigation
Five tabs: **Home · Ask AI · Study · Planner · Profile**

### v1 Scope (local-first / offline-capable, mock AI + mock subscription)
- Personalization onboarding quiz (name/nickname, grade, subjects, struggle areas, goals, learning style, daily study time) with skip/edit → personalized dashboard.
- Home dashboard: today's assignments, upcoming tests, recommended study session, study streak, weak subjects, Continue Studying + quick Ask AI buttons. Keep it uncrowded.
- Ask AI helper with "explain, don't cheat" flow: input by type/paste/photo/voice (mocked), then Explain / Hint / Walk me through / Check my answer / Make a similar problem. Adaptive tone (younger vs advanced). Deterministic mock tutor.
- Flashcards: manual + import from notes/files, decks with mastery %, difficulty, study modes (classic, multiple choice, type answer). **Spaced Repetition Scheduler** (SM-2 style due-today queue), missed cards resurface.
- Quiz generator: choose count/difficulty/type/time limit → results with score, explanations, weak topics, targeted retry quiz.
- Study guide generator from imported notes (main ideas, vocab, formulas, example questions, mini review quiz) — editable/savable.
- Planner: today/week views, assignments with class/due/difficulty/time/priority/status; AI breaks big projects into daily steps. Focus timer (10/20/25/45/custom) + post-session focus rating.
- **Study Analytics** (Swift Charts): study time, quiz score trends, flashcard mastery, streak, strongest/weakest topics — compare student to their own past, never to others.
- **Offline Study Mode**: all data persists locally via SwiftData; study/flashcards/planner fully usable without network.
- Gamification: points, badges, streaks, levels — cosmetic only, educational features stay free.

### Architecture / Data
- SwiftData models: Profile, Subject, Assignment, TestDate, Deck, Flashcard (+ SR state), QuizResult, StudySession, StudyGuide, AIConversation, Badge, subscription flag.
- On-device spaced-repetition engine (SM-2 style) and deterministic mock AI service, both structured to swap in a real backend + AI API later (key stays server-side, never in-app).
- Mock subscription gate (free limits: 5 AI questions/day, 3 scans/month) — real paywall via Superwall later.

### Deferred (post-v1)
Real AI backend, real photo OCR, real subscriptions/paywall, parent accounts, teacher dashboards, school licensing, tutoring marketplace, test-prep packs, calendar integration, referrals.