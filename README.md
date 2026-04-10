# Mission Control Mobile

Mobile companion app for Mission Control — manage agents, approvals, tasks, and leads on the go.

## Features

- 📊 **Dashboard** — Real-time stats, active agents, recent activity
- 📋 **Approvals** — Approve/reject content, code, and decisions
- ✅ **Tasks** — Kanban-style task management (Backlog → Done)
- 👥 **Leads** — Lead pipeline with scores and status tracking
- 🤖 **Agent Activity** — See who's working and for how long
- 📱 **Native Notifications** — Get notified when approvals are pending
- 🔗 **Mission Control Sync** — Reads directly from Mission Control SQLite DB

## Tech Stack

- Flutter 3.9+
- Provider (state management)
- sqflite (direct SQLite access)
- flutter_local_notifications

## Setup

### 1. Prerequisites

```bash
flutter doctor
```

### 2. Install dependencies

```bash
cd mission-control-mobile
flutter pub get
```

### 3. Run

```bash
flutter run
```

### 4. Build for iOS

```bash
flutter build ios --simulator --no-codesign
```

## Architecture

```
lib/
├── core/
│   ├── config.dart           # App configuration
│   ├── theme/                # App theme
│   └── services/             # DB, Telegram services
├── shared/
│   ├── models/               # Task, Approval, Lead, Agent models
│   └── providers/            # App state management
└── features/
    ├── dashboard/             # Dashboard screen
    ├── approvals/            # Approvals screen
    ├── tasks/                # Tasks Kanban screen
    └── leads/                # Leads screen
```

## Mission Control DB Path

The app reads from:
```
/Users/qbot/.openclaw/workspace/mission-control/data/mission-control.db
```

Make sure Mission Control is running and the database exists at this path.

## Requirements

- Flutter SDK ^3.9.2
- iOS 12.0+ / Android API 21+
- Mission Control web app running (for full sync)

## License

Private — Gonçalo Dongrie
