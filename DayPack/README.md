# DayPack — iOS app

SwiftUI app, iOS 17+. Talks to the Vapor backend in `../DayPackBackend`.

## Run it

```bash
# 1. Backend (in another terminal)
cd ../DayPackBackend
docker compose up db                  # leave running
swift run DayPackBackend migrate      # one-time
swift run DayPackBackend               # serves http://0.0.0.0:8080

# 2. iOS
open DayPack.xcworkspace
# ⌘R on any iOS 17+ simulator
```

For real-device builds, see `Run on a real iPhone` below.

## Folder map

```
DayPack/
├── DayPackApp.swift              ← @main, injects env services
├── ContentView.swift             ← Auth gate → onboarding gate → MainTabView
├── DesignSystem/                 ← Color, type, spacing, radius, shadow tokens
├── Components/                   ← Reusable views (Buttons, Cards, Inputs, …)
├── Features/                     ← One folder per screen, each with View (+ VM)
│   ├── Auth/                       Login, Register
│   ├── Onboarding/                 Welcome + 5-step setup
│   ├── Today/                      Day stack, walk-out launcher
│   ├── WalkOut/                    Checklist + Perfect Departure
│   ├── Loadouts/                   List, builder, editor, share code
│   ├── Inventory/                  Per-user item library
│   ├── Trips/                      Multi-day pack planner
│   ├── Stats/                      Streak + heatmap (off the tab bar)
│   └── Settings/                   Account, history, home location
├── Models/                       ← Item, Loadout, InventoryItem, …
├── Services/                     ← APILoadoutService, HomeLocationService, …
├── Networking/                   ← APIClient, AuthSession, KeychainTokenStore
└── Resources/                    ← Assets.xcassets, Preview content
```

## Design tokens

| Token | File | Use |
|---|---|---|
| `Color.dpOrange` etc. | `DesignSystem/DPColors.swift` | Colors |
| `.dpTitle1()`, `.dpHeadline()` etc. | `DesignSystem/DPTypography.swift` | Type styles |
| `DPSpacing.base` etc. (4–40 pt) | `DesignSystem/DPSpacing.swift` | 4pt grid |
| `DPRadius.md` etc. (8–28 pt) | `DesignSystem/DPRadius.swift` | Corner radii |
| `.dpShadow(.soft)` etc. | `DesignSystem/DPShadow.swift` | Elevation |

Use tokens, not literals. If you find yourself typing `Color(hex:)` or a raw radius value, add it to the tokens first.

## Architecture in 30 seconds

- **MVVM where it earns it.** Screens with non-trivial state have an `@Observable` ViewModel (`TodayViewModel`, `LoadoutsViewModel`, `StatsViewModel`). Trivial screens use `@State` / `@AppStorage`.
- **Service protocol + concrete impls.** `LoadoutService` is the protocol. `APILoadoutService` is the real (backend-backed) implementation; `MockLoadoutService` exists for SwiftUI previews. Inject via `@Environment(\.loadoutService)`.
- **Token storage in Keychain.** `KeychainTokenStore` persists JWTs across launches. `AuthSession` is the observable session manager — listen to `session.isLoggedIn`.

## Adding a new component

1. Create the file under the right `Components/` subfolder.
2. Use design tokens (`Color.dpOrange`, `DPSpacing.base`, `DPRadius.md`, `.dpShadow(.soft)`).
3. Add a `#Preview` showing every variant.
4. ⌘B — Xcode auto-discovers it (synchronized folders, no project-file edits).

## Run on a real iPhone

The default base URL is `http://localhost:8080`, which only works in the simulator. For a device build:

1. **Find your Mac's LAN IP**: `ipconfig getifaddr en0`
2. **Backend already binds `0.0.0.0`** — just keep it running on Mac.
3. **Override the API URL**: Xcode → Edit Scheme → Run → Environment Variables → add `DAYPACK_API_BASE_URL = http://<mac-ip>:8080`
4. **Allow HTTP to LAN**: DayPack target → Info tab → add `App Transport Security Settings` → `Allow Arbitrary Loads = YES` (dev only).
5. iPhone must be on the same Wi-Fi.

## Where to look next

- **Backlog & feature roadmap**: [`docs/BACKLOG.md`](../docs/BACKLOG.md)
- **Specs**: [`docs/superpowers/specs/`](../docs/superpowers/specs/)
- **Backend API**: `../DayPackBackend` (and the team's API doc)

## Project settings

- Deployment target: **iOS 17.0**
- Swift: 5.0 (builds on 6.x toolchains)
- Bundle ID: `com.daypack.app` (change before shipping)
- Code signing: "Sign to Run Locally" works on simulator; real device needs an Apple ID added in Xcode → Settings → Accounts.
