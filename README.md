# DayPack

Mobile Application Project 2026.

## App

The iOS project lives in [`DayPack/`](DayPack/README.md).

```bash
cd DayPack
open DayPack.xcodeproj
```

Run with Xcode 16+ on any iOS 17+ simulator.

## Team Workflow

Use short-lived feature branches off `main`:

```bash
git checkout main
git pull
git checkout -b feature/today-checklist
```

Keep `main` runnable. Open a pull request before merging feature work, even for a 2-person team.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for branch naming, commit style, ownership, and Xcode project rules.
