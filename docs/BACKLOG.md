# DayPack — Feature Backlog

Working list of what's done, what's next, and what's deferred. Treat milestones as suggestions, not contracts — re-prioritize as you learn.

---

## ✅ Milestone 1 — Foundation (shipped)

Done in `foundation` branch. See [docs/superpowers/specs/2026-04-30-daypack-component-foundation-design.md](superpowers/specs/2026-04-30-daypack-component-foundation-design.md) for the spec.

- [x] Design tokens (colors, typography, spacing, radius, shadows)
- [x] 16 reusable components with `#Preview` blocks
- [x] Mock data layer (`MockLoadoutService`)
- [x] App shell + 4-tab navigation
- [x] 6 sample screens: Onboarding Welcome, Today, Walk-Out Checklist, Loadouts, Stats, Settings
- [x] Loadout Builder modal (create new loadouts, switch active "today" loadout)

---

## 🟧 Milestone 2 — Make it feel like a real app (next)

Smallest set of changes that makes the app feel functional rather than a demo. Pick this up first.

- [ ] **Loadout Detail screen** — tap a loadout card to edit its name, schedule, items
- [ ] **Add / Edit Item modal** — full form (name, icon picker, tint picker, priority toggle, "Always" / "Optional" / "Don't forget" tag)
- [ ] **Daily reset of `ChecklistEntry.isPacked`** — when the day changes, clear packed state. Without this, users never see an "unpacked" loadout after the first day.
- [ ] **Perfect Departure success screen** — show after Walk-Out completion. Confetti optional.
- [ ] **Real streak logic** — track per-day completion in service, derive streak from history (currently returns hard-coded mock).
- [ ] **Delete item from loadout** — swipe-to-delete on `ChecklistItemRow` in Loadout Detail.
- [ ] **Reorder items in a loadout** — drag handle in edit mode.
- [ ] **Replace placeholder icons** — `mouth.fill` for toothbrush and `square.fill` for towel are awkward; pick better SF Symbols.

---

## 🟦 Milestone 3 — Persistence

Move off in-memory mock data. Required before notifications + location are useful.

- [ ] Switch `Item`, `Loadout`, `ChecklistEntry`, `DayStat` to `@Model` (SwiftData).
- [ ] Replace `MockLoadoutService` with `SwiftDataLoadoutService` behind the same `LoadoutService` protocol — views shouldn't change.
- [ ] Seed first-launch data (school day / gym day / travel) so empty state isn't the first thing users see.
- [ ] Migrate `@AppStorage` settings to a typed `UserPreferences` model.
- [ ] iCloud sync (CloudKit) — only if you have multi-device users; skip otherwise.

---

## 🟦 Milestone 4 — Reminders (notifications)

The "never forget again" promise needs notifications to actually deliver.

- [ ] Request `UNUserNotificationCenter` authorization from Settings → Reminders toggle.
- [ ] Schedule daily walk-out reminder at user-chosen time (currently just a Setting toggle that does nothing).
- [ ] "Forgot something" lock-screen notification — fires if walk-out not started by a deadline AND user is leaving home (depends on Milestone 5).
- [ ] Notification → app → Walk-Out flow deep link.
- [ ] Notification action buttons ("Mark all packed", "Snooze 5 min").

---

## 🟦 Milestone 5 — Location (geofencing)

The other half of "never forget" — knowing when the user is leaving home.

- [ ] CoreLocation auth flow (`requestAlwaysAuthorization`).
- [ ] Set Home Location onboarding screen — map + draggable pin + reverse geocode.
- [ ] Permission onboarding screen (mirrors iOS dialog).
- [ ] Geofence registration (~120m radius) on first set / on edit.
- [ ] On exit-region event → fire forgot-something notification (if loadout not packed).
- [ ] Privacy explainer in Settings (why we need location).

---

## 🟦 Milestone 6 — Full onboarding (5 more screens)

Currently we have just the Welcome screen. From the design:

- [ ] Set Home Location (depends on M5)
- [ ] Location Permission
- [ ] First Profile (preset loadout picker)
- [ ] Add Items (initial item suggestion list)
- [ ] All Set / Success
- [ ] Step indicator dots component (already designed in `DPProgressDots` — needs building)
- [ ] State machine for onboarding step + back/skip navigation
- [ ] "Reset onboarding" button in Settings already exists — verify the new flow runs through cleanly.

---

## 🟦 Milestone 7 — Stats & Insights

Make the Stats tab earn its tab slot.

- [ ] **Forgot Something** screen — list of items most often forgotten, sorted by frequency.
- [ ] Real 30-day heatmap from persisted `DayStat`.
- [ ] Per-loadout completion percentages from real history.
- [ ] Suggestion card on Today screen — "You forgot your water bottle 3x this week."
- [ ] Weekly summary push (optional).

---

## 🟦 Milestone 8 — Trip Planner

A separate sub-feature in the design — multi-day, multi-bag packing. Probably its own milestone after the core daily flow is solid.

- [ ] Trip model (start date, end date, destinations, bags, items per bag)
- [ ] Trip Planner screen (per-bag progress bars, "+ add item" per category)
- [ ] Pre-departure checklist (ID, charger, etc.)
- [ ] Packing-list templates (beach trip, business trip, hiking)

---

## 🟪 Milestone 9 — Polish

Lower priority but visible to users.

- [ ] Animations: checkbox spring, progress bar fill, screen push, sheet present.
- [ ] Confetti / success haptic on Walk-Out completion.
- [ ] Voice add (FAB on Today screen) — Speech framework, transcribe → match item.
- [ ] Empty-state illustrations (currently using SF Symbols — could be richer).
- [ ] Onboarding hero illustration (the design shows a more illustrative backpack than `backpack.fill`).
- [ ] Accessibility audit: VoiceOver labels on every component, Dynamic Type stress test, Reduce Motion fallback.
- [ ] Localization: pick languages (Thai? English?), wire `String Catalog`, audit hard-coded strings.
- [ ] Dark mode pass (currently light only).

---

## 🟫 Tech debt / quality

Tackle alongside features, not as a separate milestone.

- [ ] Unit tests for ViewModels (`TodayViewModel.togglePacked`, `LoadoutsViewModel.filtered`, `StatsViewModel.streak`).
- [ ] Snapshot tests for component variants.
- [ ] CI on GitHub Actions: build + test on every push.
- [ ] Lint with SwiftLint or SwiftFormat.
- [ ] Verify all `iOS 17+` SF Symbols (`backpack.fill`, `dumbbell.fill`, `shoeprints.fill`) render correctly on a real device.
- [ ] Replace `xcuserdata/` and other transient files in `.gitignore` (mostly already there).

---

## 💡 Ideas / parking lot

Not committed — just things to think about.

- Sharing a loadout with a friend (via link / iMessage extension).
- Apple Watch glance: today's loadout status.
- Widgets: "X of Y packed" on home screen.
- Smart-home tie-ins (don't lock the door if not packed?).
- Item barcode scan for new items.
