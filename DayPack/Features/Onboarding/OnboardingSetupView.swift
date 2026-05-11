import SwiftUI
internal import _LocationEssentials

struct OnboardingSetupView: View {
    enum Step { case permission, home, preset, items, allSet }

    @Environment(\.homeLocationService) private var home
    @Environment(\.loadoutService) private var loadoutService
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false

    @State private var step: Step = .permission
    @State private var presetName = "School Day"
    @State private var draftItems = "Wallet\nKeys\nWater Bottle\nLaptop"
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: DPSpacing.xl) {
            Spacer()
            icon
            VStack(spacing: DPSpacing.sm) {
                Text(title).dpTitle1().multilineTextAlignment(.center)
                Text(message)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.dpInk3)
                    .multilineTextAlignment(.center)
            }

            content

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.dpRed)
            }

            Spacer()

            PrimaryButton(title: primaryTitle, icon: primaryIcon) {
                Task { await advance() }
            }
            TextButton(title: "Skip setup", tone: .muted) {
                hasCompletedSetup = true
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBg.ignoresSafeArea())
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .permission:
            featureRows([
                ("location.fill", "Home geofence"),
                ("bell.fill", "Departure alerts"),
                ("checkmark.circle.fill", "Walk-Out checks"),
            ])
        case .home:
            DPCard {
                VStack(alignment: .leading, spacing: DPSpacing.sm) {
                    Text(home.hasHomeLocation ? "Home saved" : "Use current location")
                        .font(.system(size: 15, weight: .semibold))
                    Text(home.homeCoordinate.map { "\($0.latitude.formatted()), \($0.longitude.formatted())" } ?? "Tap continue while you are at home.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dpInk3)
                }
            }
        case .preset:
            Picker("Starter pack", selection: $presetName) {
                Text("School Day").tag("School Day")
                Text("Work Day").tag("Work Day")
                Text("Gym Day").tag("Gym Day")
                Text("Travel").tag("Travel")
            }
            .pickerStyle(.segmented)
        case .items:
            DPCard {
                TextEditor(text: $draftItems)
                    .font(.system(size: 15, weight: .medium))
                    .frame(minHeight: 150)
                    .scrollContentBackground(.hidden)
            }
        case .allSet:
            featureRows([
                ("house.fill", home.hasHomeLocation ? "Home ready" : "Home skipped"),
                ("backpack.fill", "Starter pack ready"),
                ("sparkles", "Smart suggestions enabled"),
            ])
        }
    }

    private var icon: some View {
        Image(systemName: iconName)
            .font(.system(size: 42, weight: .semibold))
            .foregroundStyle(Color.dpOrange)
            .frame(width: 92, height: 92)
            .background(RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous).fill(Color.dpSurface))
            .overlay(RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous).stroke(Color.dpDivider, lineWidth: 1))
    }

    private func featureRows(_ rows: [(String, String)]) -> some View {
        VStack(spacing: DPSpacing.sm) {
            ForEach(rows.indices, id: \.self) { index in
                HStack {
                    Image(systemName: rows[index].0).foregroundStyle(Color.dpOrange)
                    Text(rows[index].1).font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurface))
            }
        }
    }

    private var title: String {
        switch step {
        case .permission: return "Turn on smart departure"
        case .home: return "Set your home"
        case .preset: return "Choose a starter pack"
        case .items: return "Add essentials"
        case .allSet: return "All set"
        }
    }

    private var message: String {
        switch step {
        case .permission: return "DayPack can remind you when you physically leave home."
        case .home: return "Your home geofence starts the Walk-Out check."
        case .preset: return "Pick the pack closest to your daily routine."
        case .items: return "One item per line. You can edit these later."
        case .allSet: return "Your app is ready to use real backend data and local smart triggers."
        }
    }

    private var primaryTitle: String {
        switch step {
        case .permission: return "Allow Permissions"
        case .home: return "Use Current Location"
        case .preset: return "Continue"
        case .items: return "Create Starter Pack"
        case .allSet: return "Start Packing"
        }
    }

    private var primaryIcon: String {
        switch step {
        case .permission: return "location.fill"
        case .home: return "house.fill"
        case .preset: return "backpack.fill"
        case .items: return "plus"
        case .allSet: return "checkmark"
        }
    }

    private var iconName: String {
        switch step {
        case .permission: return "location.fill"
        case .home: return "house.fill"
        case .preset: return "backpack.fill"
        case .items: return "checklist"
        case .allSet: return "sparkles"
        }
    }

    private func advance() async {
        switch step {
        case .permission:
            home.requestPermissions()
            step = .home
        case .home:
            home.useCurrentLocationAsHome()
            step = .preset
        case .preset:
            step = .items
        case .items:
            await createStarterPack()
            step = .allSet
        case .allSet:
            hasCompletedSetup = true
        }
    }

    private func createStarterPack() async {
        let names = draftItems
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !names.isEmpty else { return }

        let items = names.enumerated().map { index, name in
            Item(name: name, symbol: symbolForItem(named: name), tint: .orange, priority: .high, tag: "Always", order: index + 1)
        }

        do {
            _ = try await loadoutService.createLoadout(
                name: presetName,
                symbol: "backpack.fill",
                tint: .orange,
                schedule: "Mon · Tue · Wed · Thu · Fri",
                items: items,
                isTemporary: false,
                alertTime: nil,
                returnAlertTime: nil
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func symbolForItem(named name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("key") { return "key.fill" }
        if lower.contains("wallet") { return "wallet.pass.fill" }
        if lower.contains("water") { return "drop.fill" }
        if lower.contains("laptop") { return "laptopcomputer" }
        if lower.contains("book") { return "book.closed.fill" }
        return "checklist"
    }
}
