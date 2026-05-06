# DayPack — Component Foundation (v0.1) Design

**Date:** 2026-04-30
**Status:** Approved (verbal — design phase 1)
**Owner:** Sunthorn Kompita
**Scope:** First implementation milestone — design tokens, reusable SwiftUI components, and a buildable Xcode project shell wired with mock data.

---

## 1. Goal

Deliver a buildable iOS Xcode project that:

1. Faithfully encodes the visual language defined in `design/DayPack Design System.html` as reusable SwiftUI primitives.
2. Provides 14 reusable components ready for teammates to drop into feature work.
3. Wires those components into 6 sample screens to demonstrate composition and intended usage.
4. Reads from in-memory mock data only — no persistence, no networking, no real location services.
5. Is approachable for a student team: clear naming, MVVM where it adds clarity, SwiftUI Previews on every component.

This is the foundation. Subsequent milestones will add real persistence, location services, the remaining 12 screens, and feature logic.

---

## 2. Scope

### In scope

- **Design tokens** (Swift): colors, typography, spacing, corner radii, shadows.
- **14 reusable components** (see §6).
- **6 sample screens**: Onboarding Welcome, Today, Walk-Out Checklist, Loadouts, Stats, Settings.
- **App shell**: `DayPackApp` entry point, root container that switches between onboarding and the main tab view.
- **Bottom tab bar** with 4 tabs (Today / Loadouts / Stats / Settings) — uses native `TabView` styled to match the design.
- **Mock data layer**: `Item`, `Loadout`, `ChecklistEntry`, `DayStat` models with sample seed data via a mock service.
- **MVVM** for screens that have non-trivial state (Today, Loadouts, Stats). Settings + Onboarding can use simple `@State` since their state is trivial.
- **SwiftUI Previews** on every component and screen.
- **README** documenting how to open and build the project, plus the SF Symbols mapping table.

### Out of scope (deferred to later milestones)

- Persistence (SwiftData / Core Data / UserDefaults beyond a single onboarding flag).
- CoreLocation / geofencing.
- Push notifications / lock-screen UI.
- Walk-Out flow animations (confetti, streak medallion).
- Add / Edit Item modal full functionality (we'll show the screen but won't wire form submit).
- Trip Planner, Forgot Something, Empty State, Perfect Departure screens.
- Accessibility audit beyond Dynamic Type compatibility.
- Localization.
- Unit tests (UI work is preview-driven for now; tests come with feature logic later).

---

## 3. Architectural decisions

| Decision | Choice | Rationale |
|---|---|---|
| Deployment target | **iOS 17.0** | Unlocks `@Observable` macro (cleaner ViewModels), `NavigationStack`, `ContentUnavailableView`. Acceptable for a 2026 student project. |
| State management | `@State` for view-local state, `@Observable` ViewModels for screens with multi-field state | One pattern, no `ObservableObject`/`@Published` boilerplate. |
| Persistence | None — in-memory mock only | User explicitly deferred. |
| Iconography | **SF Symbols** | Native, scales with Dynamic Type, free, matches iOS feel. Custom-mapped where needed (see §8). |
| Fonts | System default with `.fontDesign(.rounded)` for display headings | Matches SF Pro / SF Pro Rounded spec without shipping font files. |
| Project file | Hand-authored `DayPack.xcodeproj` (no XcodeGen / Tuist) | One less tool for the team to install. Buildable on first open. |
| Architecture | MVVM where it adds value (feature screens), pure-presentational for components | Components stay reusable. Avoids over-engineering trivial views. |
| Folder structure | Per `§4` | Matches the user-specified layout. |
| Asset catalog | Single `Assets.xcassets` with AccentColor = `dpOrange` | Lets system controls (e.g., links) inherit the brand color. |

---

## 4. Folder structure

```
DayPack/
├── DayPack.xcodeproj/                       # Hand-authored Xcode project
│   └── project.pbxproj
└── DayPack/
    ├── DayPackApp.swift                     # @main entry point
    ├── ContentView.swift                    # Root: onboarding gate + MainTabView
    ├── DesignSystem/
    │   ├── DPColors.swift                   # Color tokens as Color extensions
    │   ├── DPTypography.swift               # Font + ViewModifier-style helpers
    │   ├── DPSpacing.swift                  # CGFloat constants
    │   ├── DPRadius.swift                   # Corner-radius constants
    │   └── DPShadow.swift                   # Shadow ViewModifiers
    ├── Components/
    │   ├── Buttons/
    │   │   ├── PrimaryButton.swift
    │   │   ├── SecondaryButton.swift
    │   │   └── TextButton.swift
    │   ├── Checklist/
    │   │   ├── ChecklistItemRow.swift
    │   │   └── IconTile.swift
    │   ├── Cards/
    │   │   ├── DPCard.swift
    │   │   └── LoadoutCard.swift
    │   ├── Indicators/
    │   │   ├── ProgressBar.swift
    │   │   ├── ProgressRing.swift
    │   │   └── Pill.swift
    │   ├── Inputs/
    │   │   ├── CustomTextField.swift
    │   │   ├── SearchField.swift
    │   │   └── ToggleRow.swift
    │   ├── Layout/
    │   │   ├── SectionHeader.swift
    │   │   └── EmptyStateView.swift
    │   └── Navigation/
    │       └── BottomTabBar.swift           # Wrapper around native TabView styling
    ├── Features/
    │   ├── Onboarding/
    │   │   └── OnboardingWelcomeView.swift
    │   ├── Today/
    │   │   ├── TodayView.swift
    │   │   └── TodayViewModel.swift
    │   ├── WalkOut/
    │   │   └── WalkOutChecklistView.swift
    │   ├── Loadouts/
    │   │   ├── LoadoutsView.swift
    │   │   └── LoadoutsViewModel.swift
    │   ├── Stats/
    │   │   ├── StatsView.swift
    │   │   └── StatsViewModel.swift
    │   └── Settings/
    │       └── SettingsView.swift
    ├── Models/
    │   ├── Item.swift
    │   ├── Loadout.swift
    │   ├── ChecklistEntry.swift
    │   └── DayStat.swift
    ├── Services/
    │   ├── LoadoutService.swift             # Protocol
    │   └── MockLoadoutService.swift         # In-memory implementation
    └── Resources/
        ├── Assets.xcassets/
        │   ├── AccentColor.colorset/
        │   └── AppIcon.appiconset/
        └── Preview Content/
            └── Preview Assets.xcassets/

docs/superpowers/specs/
└── 2026-04-30-daypack-component-foundation-design.md   # this file
```

---

## 5. Design tokens (Swift API)

All tokens live under `DesignSystem/`. The naming convention is `dp` prefix on all extensions to avoid collisions.

### Colors (`DPColors.swift`)
Extends `Color` with brand, semantic, surface, and ink tokens:
```swift
Color.dpOrange       // #FF6B2C — primary brand
Color.dpOrangeDeep   // #E8531A — pressed
Color.dpOrangeSoft   // #FFE9DC — tint
Color.dpOrangeMuted  // #FFF4ED — wash
Color.dpGreen        // #2FBF71
Color.dpGreenSoft    // #E5F7EC
Color.dpRed          // #E5484D
Color.dpRedSoft      // #FFEBEC
Color.dpAmber        // #F5A524
Color.dpAmberSoft    // #FFF3DC
Color.dpBg           // #F7F5F2 — page bg
Color.dpBgGrouped    // #F2EFEA — inset surfaces
Color.dpSurface      // #FFFFFF — cards
Color.dpInk          // #1B1B1F — primary text
Color.dpInk2         // #3C3C43
Color.dpInk3         // 60% — secondary
Color.dpInk4         // 36% — tertiary / disabled
Color.dpHairline     // 10% — borders
```

### Typography (`DPTypography.swift`)
Exposed as `Font` extensions and `ViewModifier`s. Ramp matches the design system file exactly:
```swift
.font(.dpDisplay)    // 56 / -1.6 / 800 / rounded
.font(.dpTitle1)     // 32 / -0.8 / 700 / rounded
.font(.dpTitle2)     // 22 / -0.4 / 700 / rounded
.font(.dpHeadline)   // 17 / -0.2 / 600
.font(.dpBody)       // 16 / -0.2 / 500
.font(.dpSubhead)    // 14 / 0    / 500
.font(.dpCaption)    // 12.5 / 0  / 500
.font(.dpEyebrow)    // 12 / +0.5 / 700 / uppercase via modifier
```

A `.dpEyebrow()` `View` modifier wraps the eyebrow text style with `.textCase(.uppercase)` and tracking.

### Spacing (`DPSpacing.swift`)
4pt grid as `CGFloat` constants on a `DPSpacing` enum:
```swift
DPSpacing.xs   // 4
DPSpacing.sm   // 8
DPSpacing.md   // 12
DPSpacing.base // 16
DPSpacing.lg   // 20
DPSpacing.xl   // 24
DPSpacing.xxl  // 32
DPSpacing.xxxl // 40
```

### Radius (`DPRadius.swift`)
```swift
DPRadius.sm   // 8     pills, mini icons
DPRadius.md   // 14    inputs, list rows
DPRadius.lg   // 18    stat tiles
DPRadius.xl   // 22    primary cards
DPRadius.xxl  // 28    sheets, hero
DPRadius.full // 999   pills, switches
```

### Shadows (`DPShadow.swift`)
Four `ViewModifier`s applied via `.dpShadow(.soft)` etc.:
- `.soft` — list groups, default cards
- `.card` — hero, modals
- `.pop` — sheets, FAB
- `.brand` — primary CTA orange-tinted shadow

---

## 6. Component catalog

Each component is a pure SwiftUI `View` (no business logic), takes data via parameters, and ships with a `#Preview` showing every variant. Component file template:

```swift
struct ComponentName: View {
    // 1. Public init parameters
    // 2. body that uses tokens
}

#Preview { /* every variant */ }
```

| # | Component | Variants / props | Notes |
|---|---|---|---|
| 1 | `PrimaryButton` | `title`, `icon?`, `isLoading`, `isDisabled`, size (`md`/`sm`), `action` | Orange fill, brand shadow. One per screen. |
| 2 | `SecondaryButton` | `title`, `icon?`, size, `action` | Peach tint, deep-orange text. |
| 3 | `TextButton` | `title`, color (`brand` / `muted`), `action` | Tertiary actions like Cancel. |
| 4 | `ChecklistItemRow` | `item: Item`, `isPacked: Bool`, `priority: Priority?`, `tag: String?`, `onToggle: () -> Void` | States: unpacked / packed (strikethrough + green check) / high-priority (peach background). |
| 5 | `IconTile` | `symbol: String` (SF Symbol), `tint: Color` (auto-derives soft bg), size (`sm` 32 / `md` 44 / `lg` 48) | Tinted rounded icon container used in rows + cards. |
| 6 | `LoadoutCard` | `loadout: Loadout`, `isActive: Bool`, style (`default` / `compact`) | Active variant: orange border + "Today" corner badge. |
| 7 | `DPCard` | `padding`, `radius`, `shadow`, content closure | Generic white surface — base for many composites. |
| 8 | `ProgressBar` | `value: Double` (0…1), height (`lg` 10 / `sm` 6), showsLabel | Gradient fill orange→orangeDeep. Animates 220ms. |
| 9 | `ProgressRing` | `value: Double`, size, lineWidth | Used in Walk-Out hero. |
| 10 | `Pill` | `text`, style (`default` / `brand` / `warn` / `success`) | Small status chip. |
| 11 | `CustomTextField` | `label`, `text: Binding<String>`, `placeholder`, `icon?`, `isFocused` (computed) | Two-line variant with floating label above value. |
| 12 | `SearchField` | `text: Binding<String>`, `placeholder` | Single-line with leading magnifier. |
| 13 | `ToggleRow` | `title`, `subtitle?`, `isOn: Binding<Bool>` | Settings-row pattern with right-aligned switch. |
| 14 | `SectionHeader` | `title`, `eyebrow?`, `trailingAction?` | Used above lists/groups. |
| 15 | `EmptyStateView` | `symbol`, `title`, `message`, `cta?` | Reusable across empty lists. |
| 16 | `BottomTabBar` | (internal) | Not a custom view — applied via `.tabBarStyle()` modifier on the root `TabView` to recolor + adjust the native bar to match the design. Listed here for completeness. |

> The list grew from 14 to 16 because `IconTile` and `DPCard` were extracted as helpers used by multiple top-level components. They earn their keep.

---

## 7. Sample screens

### 7.1 OnboardingWelcomeView
Centered hero icon (white card with `backpack` SF Symbol on orange tint), Title 1 "Never Forget Again", subtitle, primary button "Get Started", text button "I already have an account". Sets `hasOnboarded = true` in `@AppStorage` on tap.

### 7.2 TodayView
- Large nav title "Today" + subtitle "Tuesday · Mar 5"
- Status banner pill ("At Home")
- Active `LoadoutCard` (School Day)
- "3 of 6 packed" `ProgressBar.lg` with label
- 4 `ChecklistItemRow`s (compact density)
- `PrimaryButton` "Start Walk-Out Check" → pushes `WalkOutChecklistView`
- `TodayViewModel` exposes `loadout`, `entries`, `progress`, `togglePacked(_:)`.

### 7.3 WalkOutChecklistView
- Compact NavBar (back chevron + close X)
- `ProgressRing` (large) with packed count center label
- Group sections: Essentials / Loadout / Optional, each with `SectionHeader` (eyebrow + count)
- Full-density `ChecklistItemRow`s with `Pill` tags
- `PrimaryButton` "I'm Ready to Go" at bottom (disabled until all required items packed)

### 7.4 LoadoutsView
- Large nav title "Loadouts" + plus button
- `SearchField` ("Search loadouts & items")
- Grid of `LoadoutCard`s — first one active
- Empty state if mock data list is empty (won't trigger by default; included for completeness)
- `LoadoutsViewModel` exposes `loadouts`, `searchText`, `filtered: [Loadout]`.

### 7.5 StatsView
- Streak hero card (gradient orange) — "13 day streak" with week dots (7 small circles, packed days filled)
- 30-day "perfect days" heatmap as a 5×6 grid of dots colored by completion %
- Per-loadout `ProgressBar.sm` rows ("School Day — 92%", etc.)
- `StatsViewModel` exposes `streak`, `weekDots`, `heatmap`, `perLoadout`.

### 7.6 SettingsView
- Sections (`SectionHeader`):
  - Reminders — `ToggleRow`s for Walk-out reminder, Forgot-something nudge
  - Items — `ToggleRow` for High-priority highlighting, Recurring suggestions
  - About — version row, GitHub row
- Plain `@State` for each toggle; no VM needed.

---

## 8. Models & mock data

### Models (`Models/`)

```swift
struct Item: Identifiable, Hashable {
    let id: UUID
    var name: String
    var symbol: String         // SF Symbol name
    var tint: ItemTint         // .green, .orange, .red, .blue, .purple, .teal
    var priority: Priority     // .low, .normal, .high
    var tag: String?           // "Always", "Optional", "Don't forget"
}

struct Loadout: Identifiable, Hashable {
    let id: UUID
    var name: String           // "School Day"
    var symbol: String         // SF Symbol
    var tint: ItemTint
    var schedule: String       // "Mon · Wed · Fri" — free-form for now
    var itemIDs: [UUID]
}

struct ChecklistEntry: Identifiable, Hashable {
    let id: UUID
    let itemID: UUID
    var isPacked: Bool
}

struct DayStat: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var completion: Double     // 0.0…1.0
}

enum Priority: String { case low, normal, high }
enum ItemTint: String { case green, orange, red, blue, purple, teal }
```

### Mock service (`Services/`)
```swift
protocol LoadoutService {
    func loadoutsForToday() -> [Loadout]
    func allLoadouts() -> [Loadout]
    func items(for loadout: Loadout) -> [Item]
    func entries(for loadout: Loadout) -> [ChecklistEntry]
    func togglePacked(entryID: UUID)
    func recentDayStats(days: Int) -> [DayStat]
}

final class MockLoadoutService: LoadoutService { /* in-memory seed */ }
```

Seed data (lives at the top of `MockLoadoutService.swift` for easy editing):
- 3 loadouts: **School Day** (active today), **Gym Day**, **Travel**
- ~14 items spread across them: Notebook, Water Bottle, Laptop, Headphones, Wallet, Keys, Protein Shake, Gym Shoes, Towel, Passport, Charger, Toothbrush, Earbuds, Umbrella
- 30 days of `DayStat` with realistic completion variance for the heatmap

The service is shared via the `@Environment` so views grab it without prop-drilling. (Not full DI — just `EnvironmentValues` extension.)

---

## 9. SF Symbols mapping

The HTML uses inline SVG icons. Each one maps to an SF Symbol in our project. Documented in `README.md` and at the call site where helpful.

| Design icon | SF Symbol | Usage |
|---|---|---|
| backpack | `backpack` (iOS 17+) | App brand, Loadouts tab |
| check | `checkmark` | Packed-state checkbox glyph |
| plus | `plus` | Add buttons |
| chevR / chevL / chevD | `chevron.right` / `chevron.left` / `chevron.down` | Navigation |
| close | `xmark` | Modal dismissals |
| bell | `bell.fill` | Notifications |
| pin | `mappin.and.ellipse` | Location |
| search | `magnifyingglass` | Search field |
| gear | `gearshape.fill` | Settings tab |
| flame | `flame.fill` | Streak / Stats tab |
| dumbbell | `dumbbell.fill` (iOS 17+) | Gym Day loadout |
| book | `book.closed.fill` | School Day loadout |
| plane | `paperplane.fill` | Travel loadout |
| briefcase | `briefcase.fill` | Work loadout |
| home | `house.fill` | Home location |
| list | `list.bullet` | Lists |
| sun | `sun.max.fill` | Today tab |
| moon | `moon.fill` | Night |
| water | `drop.fill` | Water bottle item |
| shoe | `shoe.fill` (iOS 17+) | Shoes item |
| headphones | `headphones` | Headphones item |
| laptop | `laptopcomputer` | Laptop item |
| key | `key.fill` | Keys item |
| wallet | `wallet.pass.fill` | Wallet item |
| umbrella | `umbrella.fill` | Umbrella item |
| toothbrush | `mouth.fill` | Toothbrush item (no exact match; closest is mouth) |
| edit | `pencil` | Edit actions |
| trash | `trash.fill` | Delete |
| sparkle | `sparkles` | Suggestions |
| calendar | `calendar` | Schedule |
| clock | `clock.fill` | Reminders |
| arrow | `arrow.right` | Forward action |

Where a symbol requires iOS 17+ (`backpack`, `dumbbell`, `shoe`), our deployment target already covers it.

---

## 10. Implementation plan

Order matters — each step depends on the previous one. We'll commit at meaningful checkpoints (after tokens, after components, after screens, final).

1. **Scaffold** — Generate `DayPack.xcodeproj` + folder structure. Verify it opens and an empty `DayPackApp` builds.
2. **Design tokens** — `DPColors`, `DPTypography`, `DPSpacing`, `DPRadius`, `DPShadow`. Each with a preview swatch.
3. **Models + mock service** — Plain Swift types + `MockLoadoutService` + `EnvironmentKey` for injection.
4. **Primitive components** — `DPCard`, `IconTile`, `Pill`, `ProgressBar`, `ProgressRing`, `SectionHeader`, `EmptyStateView`. Each with `#Preview`.
5. **Form components** — `CustomTextField`, `SearchField`, `ToggleRow`.
6. **Button components** — `PrimaryButton`, `SecondaryButton`, `TextButton`.
7. **Composite components** — `ChecklistItemRow`, `LoadoutCard`. Each composes the primitives above.
8. **App shell** — `DayPackApp`, `ContentView` (onboarding gate), `MainTabView` with custom-styled `TabView`.
9. **Sample screens** — In order: Onboarding → Today → Walk-Out → Loadouts → Stats → Settings. Each with VM where called for.
10. **README** — How to open / build, folder map, SF Symbols mapping table, a "where to add a new component" guide for teammates.

Each component is its own file with a self-contained `#Preview`. This makes the project navigable and lets a teammate iterate on any single component in isolation.

---

## 11. Open questions / future work

- **Animation polish** — checkbox tap, progress fill, screen transitions. Defer to milestone 2.
- **Walk-Out flow polish** — confetti, streak medallion, "Perfect Departure" hero card.
- **Real persistence** — likely SwiftData given iOS 17 target. Will need migration plan from mock service.
- **Accessibility** — full VoiceOver labels, Dynamic Type stress test, Reduce Motion fallback for animations.
- **Localization** — string catalog from day one of milestone 2 to avoid retrofitting.
- **Custom backpack-bag illustrations** — the onboarding hero uses a more illustrative style than SF Symbols can match; design team to decide if we ship an illustration set.
- **Trip Planner screen** — out of scope for this milestone but designed; needs its own component (`TripProgressGroup`).
