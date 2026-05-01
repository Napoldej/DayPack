# Contributing to DayPack

This project is set up for a small 2-person SwiftUI team. Keep the workflow simple and keep `main` runnable.

## Branches

- `main` is the stable branch. It should always build.
- Create one branch per task or feature.
- Use names like:
  - `feature/today-checklist`
  - `feature/loadout-editor`
  - `fix/settings-toggle-state`
  - `chore/readme-cleanup`

## Commits

Write small, meaningful commits in the imperative style:

```text
Add walk-out checklist sections
Fix loadout search filtering
Extract settings preference store
```

Avoid large mixed commits that combine unrelated UI, model, and project setup changes.

## Pull Requests

- Open a pull request before merging into `main`.
- One teammate reviews before merge.
- Keep PRs focused on one feature area when possible.
- Mention any shared files touched, especially app navigation, services, models, or design tokens.

## Suggested Ownership

To reduce conflicts, split work by feature folder:

- Developer A: `Features/Today`, `Features/WalkOut`, checklist behavior.
- Developer B: `Features/Loadouts`, `Features/Settings`, loadout editing.
- Shared folders (`DesignSystem`, `Components`, `Models`, `Services`) should be changed in small PRs.

## Xcode Rules

- Use Xcode 16+.
- The project uses synchronized folders, so adding a `.swift` file under `DayPack/DayPack/` should not require manual `.pbxproj` edits.
- Do not commit `xcuserdata/`.
- Avoid manually editing `DayPack.xcodeproj/project.pbxproj` unless project settings actually need to change.
- If there is a `.pbxproj` conflict, resolve it carefully and verify the app opens in Xcode before merging.

## Before Merging

Run or check:

```bash
cd DayPack
xcodebuild -project DayPack.xcodeproj -scheme DayPack -destination 'platform=iOS Simulator,name=iPhone 16' build
```

If the exact simulator is not installed, build from Xcode on any iOS 17+ simulator and mention that in the PR.

## Architecture Direction

- Keep SwiftUI views focused on layout and interactions.
- Put screen state and derived logic in feature view models.
- Keep reusable UI in `Components`.
- Keep visual tokens in `DesignSystem`.
- Add future persistence under a dedicated `Storage` or `Repositories` layer instead of putting database code directly into views.
