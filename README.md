# DayPack

DayPack is a native iOS packing assistant that helps users prepare the right items before leaving home. Users create reusable loadout profiles, manage personal inventory items, set a home location, and run a walk-out checklist so required items are not forgotten.

The repository contains two main parts:

- `DayPack/` — SwiftUI iOS app
- `DayPackBackend/` — Vapor + PostgreSQL API

## Features

- **Authentication**: register, login, account update, account deletion.
- **Onboarding**: first-time setup for account, home location, and starter loadout.
- **Loadouts**: create packing profiles for contexts like university, work, gym, and travel.
- **Inventory**: save reusable personal items and add them to loadouts or trip plans.
- **Today**: show the active packing checklist for the user's current day.
- **Walk-Out Check**: required items must be packed before the final departure confirmation.
- **Home Geofence**: iOS local notification can open the walk-out checklist when the user leaves home.
- **Trip Planner**: plan trip packing using saved inventory items.
- **History**: view previous check sessions from the backend.

## Requirements

| Tool | Version / Notes |
|---|---|
| macOS | Ventura or newer recommended |
| Xcode | 16+ |
| iOS Simulator | iOS 17+ |
| Swift | Swift 6 toolchain for backend |
| Docker Desktop | Required for local PostgreSQL |

## Project Structure

```text
DayPack/
├── DayPack/                    # iOS app source
│   ├── Components/             # Shared SwiftUI components
│   ├── DesignSystem/           # Colors, spacing, typography, radius, shadows
│   ├── Features/               # App screens and view models
│   ├── Models/                 # App-side models
│   ├── Networking/             # API client, auth session, keychain token storage
│   └── Services/               # Loadout, inventory, notification, location services
├── DayPackBackend/             # Vapor backend
│   ├── Sources/DayPackBackend/
│   │   ├── Controllers/        # Route handlers
│   │   ├── DTOs/               # Request/response data types
│   │   ├── Middlewares/        # JWT middleware
│   │   ├── Migrations/         # Fluent database migrations
│   │   ├── Models/             # Fluent models
│   │   ├── Repositories/       # Database access
│   │   └── Services/           # Business logic
│   └── docker-compose.yml      # Local PostgreSQL and app containers
├── CONTRIBUTING.md             # Team workflow
└── README.md
```

## Quick Start

Run the backend first, then launch the iOS app.

### 1. Clone the repository

```bash
git clone https://github.com/Napoldej/DayPack.git
cd DayPack
```

If you already have the project locally, start from the repository root instead.

### 2. Start PostgreSQL

```bash
cd DayPackBackend
docker compose up db
```

Leave this terminal running.

### 3. Run database migrations

Open a second terminal:

```bash
cd DayPackBackend
swift run DayPackBackend migrate
```

When prompted, confirm with `y`.

### 4. Start the backend API

```bash
cd DayPackBackend
swift run DayPackBackend
```

The API should be available at:

```text
http://localhost:8080
```

Check it with:

```bash
curl http://localhost:8080
```

### 5. Run the iOS app

From the repository root:

```bash
open DayPack.xcodeproj
```

Choose an iOS 17+ simulator and press `Cmd+R`.

The iOS app defaults to:

```text
http://localhost:8080
```

You can override the API base URL with either:

- `DAYPACK_API_BASE_URL` environment variable
- `UserDefaults` key `api.baseURL`

## Backend Commands

Run these from `DayPackBackend/`.

| Command | Description |
|---|---|
| `docker compose up db` | Start PostgreSQL only |
| `docker compose up app` | Build and run backend container |
| `docker compose run migrate` | Run migrations in Docker |
| `docker compose run revert` | Revert last migration in Docker |
| `docker compose down` | Stop containers |
| `docker compose down -v` | Stop containers and delete database volume |
| `swift build` | Build backend locally |
| `swift run DayPackBackend` | Run backend locally |
| `swift run DayPackBackend migrate` | Run migrations locally |
| `swift run DayPackBackend migrate --revert` | Revert last migration locally |
| `swift test` | Run backend tests |

## iOS Commands

Run these from the repository root unless noted.

| Command | Description |
|---|---|
| `open DayPack.xcodeproj` | Open the app in Xcode |
| `xcodebuild -project DayPack.xcodeproj -scheme DayPack -destination 'generic/platform=iOS' build` | CLI build check |

The app uses Xcode synchronized folders, so new Swift files under `DayPack/` are picked up automatically by Xcode 16+.

## API Overview

Summary of the backend routes used by the iOS app:

### Public Routes

| Method | Route | Description |
|---|---|---|
| `GET` | `/` | Health check |
| `GET` | `/hello` | Example route |
| `POST` | `/auth/register` | Create an account |
| `POST` | `/auth/login` | Log in and receive JWT |

### Protected Routes

Protected routes require:

```http
Authorization: Bearer <token>
```

| Area | Main Routes | Purpose |
|---|---|---|
| Users | `/users` | List, read, update, delete users |
| Loadouts | `/loadouts` | Create and manage loadout profiles |
| Tomorrow Suggestions | `/loadouts/tomorrow` | Get scheduled/temporary packs for tomorrow |
| Items | `/items` | Manage items inside loadouts |
| Check Sessions | `/check-sessions` | Start and complete packing checks |
| Check Items | `/check-items` | Toggle individual checklist items |
| Shared Packs | `/shared-packs` | Backend support for pack sharing records |
| Share Codes | `/share-codes` | Backend support for generating, previewing, and importing pack codes |

### Example: Register

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Win",
    "email": "win@example.com",
    "password": "password123"
  }'
```

### Example: Get Loadouts

```bash
curl "http://localhost:8080/loadouts?userID=<USER_ID>" \
  -H "Authorization: Bearer <TOKEN>"
```

## Database

Local Docker database defaults:

| Field | Value |
|---|---|
| Host | `localhost` locally, `db` inside Docker |
| Port | `5432` |
| Database | `vapor_database` |
| Username | `vapor_username` |
| Password | `vapor_password` |

The backend reads the same values from `DayPackBackend/docker-compose.yml` and Vapor configuration.
