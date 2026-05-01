# DayPack — iOS app

Mock-data v0.1 component foundation. SwiftUI + iOS 17.0.

## Open the project

```bash
open DayPack.xcodeproj
```

Then **⌘R** to run on any iOS 17+ simulator.

> The project uses Xcode 16+ synchronized folders — Xcode automatically picks up every `.swift` file inside `DayPack/`, so adding a new file means dropping it into the right folder. No drag-into-project dance.

## Collaboration rules

- Use Xcode 16+.
- Work on short-lived feature branches off `main`.
- Keep feature work inside the relevant `Features/...` folder when possible.
- Change shared folders (`Components`, `DesignSystem`, `Models`, `Services`) in small, focused PRs.
- Do not commit `xcuserdata/`.
- Avoid manual edits to `DayPack.xcodeproj/project.pbxproj`; synchronized folders should pick up new Swift files automatically.

See `../CONTRIBUTING.md` for the full 2-person workflow.

## Folder map

```
DayPack/
├── DayPackApp.swift            ← @main entry point
├── ContentView.swift           ← Root: onboarding gate + MainTabView
├── DesignSystem/               ← Tokens (colors, typography, spacing, radius, shadow)
├── Components/                 ← Reusable UI building blocks
│   ├── Buttons/                  PrimaryButton, SecondaryButton, TextButton
│   ├── Checklist/                ChecklistItemRow, IconTile
│   ├── Cards/                    DPCard, LoadoutCard
│   ├── Indicators/               ProgressBar, ProgressRing, Pill
│   ├── Inputs/                   CustomTextField, SearchField, ToggleRow
│   └── Layout/                   SectionHeader, EmptyStateView
├── Features/                   ← One folder per screen — View + ViewModel
│   ├── Onboarding/               OnboardingWelcomeView
│   ├── Today/                    TodayView (+ VM)
│   ├── WalkOut/                  WalkOutChecklistView
│   ├── Loadouts/                 LoadoutsView (+ VM)
│   ├── Stats/                    StatsView (+ VM)
│   ├── Settings/                 SettingsView
│   └── MainTabView.swift         Root tab container
├── Models/                     ← Item, Loadout, ChecklistEntry, DayStat
├── Services/                   ← LoadoutService protocol + MockLoadoutService
└── Resources/
    ├── Assets.xcassets         ← AppIcon, AccentColor (= dpOrange)
    └── Preview Content/        ← Dev-only preview assets
```

## Adding a new component

1. Create a new `.swift` file under the right `Components/` subfolder.
2. Build the view as a `struct ... : View`. Use design tokens (`Color.dpOrange`, `DPSpacing.base`, `DPRadius.md`, `.dpShadow(.soft)`).
3. Add a `#Preview` showing every variant.
4. Hit ⌘B — Xcode will auto-discover the file.

That's it — no project file edits, no group manipulation.

## Design tokens at a glance

| Token | Where | Usage |
|---|---|---|
| `Color.dpOrange` etc. | `DesignSystem/DPColors.swift` | All colors |
| `.dpTitle1()`, `.dpHeadline()` etc. | `DesignSystem/DPTypography.swift` | Text styles |
| `DPSpacing.base` etc. | `DesignSystem/DPSpacing.swift` | 4pt grid (`xs`=4 → `xxxl`=40) |
| `DPRadius.md` etc. | `DesignSystem/DPRadius.swift` | Corner radii (`sm`=8 → `xxl`=28) |
| `.dpShadow(.soft)` etc. | `DesignSystem/DPShadow.swift` | `soft` / `card` / `pop` / `brand` |

Every token traces back to the tokens defined in `design/DayPack Design System.html`.

## SF Symbols mapping

The hi-fi designs use custom SVG icons. We map each to the closest SF Symbol. iOS 17+ symbols are noted with a star.

| Design icon | SF Symbol | Used in |
|---|---|---|
| backpack | `backpack.fill` ★ | App brand, Loadouts tab |
| check | `checkmark` | Packed-state |
| plus | `plus`, `plus.circle.fill` | Add buttons |
| chevR / chevL / chevD | `chevron.right` / `chevron.left` / `chevron.down` | Navigation |
| close | `xmark` | Modal dismiss |
| bell | `bell.fill` | Notifications |
| pin | `mappin.and.ellipse` | Location |
| search | `magnifyingglass` | SearchField |
| gear | `gearshape.fill` | Settings tab |
| flame | `flame.fill` | Streak / Stats tab |
| dumbbell | `dumbbell.fill` ★ | Gym Day loadout |
| book | `book.closed.fill` | School Day loadout |
| plane | `paperplane.fill` | Travel loadout |
| briefcase | `briefcase.fill` | Work loadout |
| home | `house.fill` | Home location |
| list | `list.bullet` | Lists |
| sun | `sun.max.fill` | Today tab |
| moon | `moon.fill` | Night |
| water | `drop.fill` / `drop.halffull` | Water bottle / shake items |
| shoe | `shoeprints.fill` ★ | Shoes item |
| headphones | `headphones`, `earbuds` | Audio items |
| laptop | `laptopcomputer` | Laptop item |
| key | `key.fill` | Keys item |
| wallet | `wallet.pass.fill` | Wallet item |
| umbrella | `umbrella.fill` | Umbrella item |
| toothbrush | `mouth.fill` | Toothbrush (no exact match — closest visual) |
| edit | `pencil` | Edit actions |
| trash | `trash.fill` | Delete |
| sparkle | `sparkles` | Suggestions |
| calendar | `calendar` | Schedule |
| clock | `clock.fill` | Reminders |
| arrow | `arrow.right` | Forward |
| power | `powerplug.fill` | Charger item |
| document | `doc.text.fill` | Passport item |

Browse these in [SF Symbols.app](https://developer.apple.com/sf-symbols/) to see how they look at every weight and size.

## Architecture

**MVVM, lightly applied.** Reusable components are pure SwiftUI views with no view model — they take data via parameters. Screens with non-trivial state get an `@Observable` ViewModel (`TodayViewModel`, `LoadoutsViewModel`, `StatsViewModel`). Trivial screens (Settings, Onboarding) use plain `@State` / `@AppStorage`.

**Mock data.** `MockLoadoutService` is the single source of truth for now. It's injected via `@Environment(\.loadoutService)` so views grab it without prop-drilling. When we move to a real persistence layer, only the service changes — view code stays identical.

**State management cheat sheet:**
- View-local toggles → `@State`
- Persisted user preferences → `@AppStorage`
- Multi-field screen state → `@Observable` ViewModel
- Cross-screen mock data → `@Environment(\.loadoutService)`

## What's in scope vs. deferred

**In scope (this milestone):** design tokens, 16 reusable components, 6 sample screens, mock data, MVVM, SwiftUI Previews on every component.

**Deferred:** persistence (SwiftData), CoreLocation / geofencing, push notifications, Add/Edit Item modal logic, Trip Planner / Forgot Something / Empty State / Perfect Departure screens, animation polish, accessibility audit, localization.

See `docs/superpowers/specs/2026-04-30-daypack-component-foundation-design.md` for the full design spec.

## Project setup notes

- **Deployment target:** iOS 17.0
- **Swift:** 5.0 (compiles on 6.x toolchains)
- **Synchronized folders:** Xcode 16+ feature, requires `objectVersion = 77`
- **Bundle ID:** `com.daypack.app` (change in Signing & Capabilities before shipping)
- **Code signing:** "Sign to Run Locally" — works on simulator without an Apple Developer account
