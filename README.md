# Nexus Interview AI

An intelligent career-coaching platform that helps IT specialists prepare for
job interviews, optimise their resumes, and discover relevant remote
opportunities — powered by Claude (Anthropic), FastAPI, and React.

This repository contains a full-stack reference implementation built as a
diploma project. It includes a production-style FastAPI backend, a React +
Vite + Tailwind frontend, an SQLAlchemy 2.0 async data layer, and Alembic
migrations.

---

## Features

- **Voice interview HUD.** Web Speech API records the candidate's answers in
  real time and reads each AI question aloud. Live metrics — confidence,
  WPM, filler words, clarity — are computed per turn.
- **Resume Studio.** Upload a CV (PDF / DOCX / TXT) and receive an ATS
  score, missing-keyword analysis, and a Claude-rewritten markdown copy
  rendered into a polished PDF.
- **Resume Builder wizard.** Step-by-step questionnaire that produces a
  fully-formatted, ATS-friendly resume markdown + PDF.
- **AI coaching chat.** Multi-turn conversations grounded in the user's
  uploaded resume.
- **Live job board.** RemoteOK + Findwork.dev aggregator with a Claude AI
  fallback that always returns role-relevant listings, filtered to 15
  developer specialisations.
- **Tasks & gamification.** XP, daily streaks, and a curated task library
  per role.
- **i18n.** Full English / Ukrainian translations.

## Repository layout

```
.
├── README.md              ← you are here
├── .env.example           ← template — copy to .env and fill in
├── .gitignore
├── docker-compose.yml     ← one-shot local stack (Postgres + API + Web)
├── start.bat              ← Windows: install + run
├── setup.bat              ← Windows: install only
├── stop.bat               ← Windows: docker-compose down
│
├── backend/               ← FastAPI + SQLAlchemy 2.0 (async)
│   ├── backend/           ← Python package
│   │   ├── api/           ← REST endpoints
│   │   ├── core/          ← config, security, bootstrap
│   │   ├── db/            ← SQLAlchemy models + session
│   │   ├── schemas/       ← Pydantic v2 schemas
│   │   ├── services/      ← Claude, parser, PDF, scoring
│   │   └── main.py        ← FastAPI entry point
│   ├── alembic/           ← migrations
│   ├── scripts/           ← admin/maintenance helpers
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/              ← React 18 + Vite + Tailwind
│   ├── src/
│   │   ├── api/           ← typed fetch clients
│   │   ├── components/    ← shared UI (TopNav, BentoWidget, …)
│   │   ├── context/       ← AppContext (auth, profile, screen)
│   │   ├── i18n/          ← en.json, uk.json
│   │   ├── pages/         ← Landing, Auth, Onboarding, Dashboard,
│   │   │                    InterviewHUD, ResumeStudio, Jobs, …
│   │   └── main.jsx
│   └── package.json
│
├── docs/                  ← thesis / conference materials (.docx)
└── scripts/               ← cross-platform launchers
    ├── start.ps1          ← real launcher invoked by start.bat
    ├── _run_backend.bat   ← run backend only (after setup)
    └── _run_frontend.bat  ← run frontend only
```

## Prerequisites

| Tool         | Version       |
|--------------|---------------|
| Python       | 3.11 or newer |
| Node.js      | 20 or newer   |
| npm          | 10 or newer   |
| (optional) Docker | 24 + Compose v2 |

An Anthropic API key is recommended but not required — the app falls back
to deterministic mock data when `ANTHROPIC_API_KEY` is empty.

## Quick start (Windows, no Docker)

```bat
:: 1. Configure environment
copy .env.example .env
:: edit .env and paste your ANTHROPIC_API_KEY (optional)

:: 2. Install dependencies (one-off)
setup.bat

:: 3. Launch app
start.bat
```

The launcher opens two console windows (backend on `:8000`, frontend on
`:5173`) and a browser tab at <http://localhost:5173>.

## Quick start (manual / cross-platform)

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload
```

API docs: <http://localhost:8000/docs>

### Frontend

```bash
cd frontend
npm install
npm run dev -- --host
```

App: <http://localhost:5173>

## Quick start (Docker)

```bash
cp .env.example .env              # then edit
docker compose up --build
```

This starts PostgreSQL, the FastAPI service, and the Vite dev server
together. Stop with `stop.bat` (Windows) or `docker compose down`.

## Configuration

All runtime configuration is via environment variables. See
[`.env.example`](.env.example) for the full list. Highlights:

| Variable               | Purpose                                            |
|------------------------|----------------------------------------------------|
| `SECRET_KEY`           | JWT signing key — **must** be changed in prod      |
| `ANTHROPIC_API_KEY`    | Claude API key (Resume / Interview / Jobs AI)      |
| `DATABASE_URL`         | Empty → SQLite. Or a Postgres DSN.                 |
| `FINDWORK_API_KEY`     | Optional — extra job board source                  |
| `ADMIN_EMAILS`         | Comma-separated emails auto-promoted to admin      |
| `ADMIN_PROMOTE_SECRET` | Shared secret for the admin-promote endpoint       |

## Tech stack

**Backend** — FastAPI, SQLAlchemy 2.0 (async), Alembic, Pydantic v2,
PyJWT, PyMuPDF, ReportLab, python-docx, httpx, anthropic, aiosqlite,
asyncpg, pytest + asgi-lifespan.

**Frontend** — React 18, Vite 5, Tailwind CSS 3, i18next, lucide-react,
axios.

**External** — Anthropic Claude (`claude-sonnet-4`), RemoteOK, Findwork.dev,
Web Speech API (browser-native STT + TTS).

## API surface (selected)

| Method | Path                          | Purpose                          |
|--------|-------------------------------|----------------------------------|
| POST   | `/api/v1/auth/register`       | Email/password signup            |
| POST   | `/api/v1/auth/login`          | Returns access + refresh tokens  |
| GET    | `/api/v1/users/me`            | Current user profile             |
| POST   | `/api/v1/resume/upload`       | PDF/DOCX/TXT → ATS analysis      |
| POST   | `/api/v1/resume/build`        | Structured wizard → markdown     |
| POST   | `/api/v1/resume/generate`     | Latest markdown → polished PDF   |
| POST   | `/api/v1/resume/chat`         | AI resume coaching chat          |
| POST   | `/api/v1/interview/start`     | Begin live session               |
| POST   | `/api/v1/interview/process_audio_text` | Submit answer → metrics |
| GET    | `/api/v1/jobs`                | Role-filtered remote listings    |
| GET    | `/api/v1/dashboard`           | Aggregated user dashboard        |
| GET    | `/api/v1/tasks`               | Per-role task library            |

Full interactive schema at `/docs` (Swagger UI) and `/redoc`.

## Testing

```bash
cd backend
pytest -q
```

Tests use `asgi-lifespan` so the FastAPI startup hooks (admin bootstrap,
table creation) run inside the test client. The default test runner uses
SQLite via `aiosqlite`.

## License

This repository is the source code of a diploma project and is provided
as-is for academic review.
