import SwiftUI
import MapKit
internal import _LocationEssentials

struct OnboardingSetupView: View {
    private enum Step: Int, CaseIterable {
        case intro = 1
        case home = 2
        case loadout = 3
        case done = 4
    }

    private struct StarterTemplate: Identifiable, Hashable {
        let id: String
        let name: String
        let subtitle: String
        let symbol: String
        let tint: ItemTint
        let schedule: String
        let items: [Item]
    }

    @Environment(\.authSession) private var session
    @Environment(\.homeLocationService) private var home
    @Environment(\.loadoutService) private var loadoutService

    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @AppStorage("setupRevision") private var setupRevision = 0

    @State private var step: Step = .intro
    @State private var selectedTemplateID = "student"
    @State private var createdLoadoutName = "Student"
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var mapPosition: MapCameraPosition = .automatic

    private let templates: [StarterTemplate] = [
        StarterTemplate(
            id: "student",
            name: "Student",
            subtitle: "Class essentials",
            symbol: "book.closed.fill",
            tint: .green,
            schedule: "Mon · Tue · Wed · Thu · Fri",
            items: [
                Item(name: "Notebook", symbol: "book.closed.fill", tint: .green, priority: .high, tag: "Always", order: 1),
                Item(name: "Laptop", symbol: "laptopcomputer", tint: .blue, priority: .high, tag: "Always", order: 2),
                Item(name: "Charger", symbol: "powerplug.fill", tint: .green, priority: .high, tag: "Always", order: 3),
                Item(name: "Pen", symbol: "pencil", tint: .orange, order: 4),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue, order: 5),
                Item(name: "Keys", symbol: "key.fill", tint: .orange, priority: .high, tag: "Always", order: 6),
            ]
        ),
        StarterTemplate(
            id: "office",
            name: "Office",
            subtitle: "Work commute",
            symbol: "briefcase.fill",
            tint: .orange,
            schedule: "Mon · Tue · Wed · Thu · Fri",
            items: [
                Item(name: "Laptop", symbol: "laptopcomputer", tint: .blue, priority: .high, tag: "Always", order: 1),
                Item(name: "Charger", symbol: "powerplug.fill", tint: .green, priority: .high, tag: "Always", order: 2),
                Item(name: "Badge", symbol: "person.text.rectangle.fill", tint: .orange, priority: .high, tag: "Always", order: 3),
                Item(name: "Notebook", symbol: "book.closed.fill", tint: .green, order: 4),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue, order: 5),
            ]
        ),
        StarterTemplate(
            id: "gym",
            name: "Gym",
            subtitle: "Workout kit",
            symbol: "dumbbell.fill",
            tint: .purple,
            schedule: "Tue · Thu",
            items: [
                Item(name: "Gym Shoes", symbol: "shoeprints.fill", tint: .green, priority: .high, tag: "Always", order: 1),
                Item(name: "Gym Clothes", symbol: "tshirt.fill", tint: .blue, priority: .high, tag: "Always", order: 2),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue, order: 3),
                Item(name: "Towel", symbol: "square.fill", tint: .teal, order: 4),
            ]
        ),
        StarterTemplate(
            id: "traveler",
            name: "Traveler",
            subtitle: "Day trips",
            symbol: "paperplane.fill",
            tint: .teal,
            schedule: "Manual",
            items: [
                Item(name: "Wallet", symbol: "wallet.pass.fill", tint: .orange, priority: .high, tag: "Always", order: 1),
                Item(name: "Keys", symbol: "key.fill", tint: .orange, priority: .high, tag: "Always", order: 2),
                Item(name: "Power Bank", symbol: "battery.100", tint: .green, order: 3),
                Item(name: "Umbrella", symbol: "umbrella.fill", tint: .blue, order: 4),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue, order: 5),
            ]
        ),
    ]

    private var selectedTemplate: StarterTemplate {
        templates.first { $0.id == selectedTemplateID } ?? templates[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    header
                    stepContent

                    if let errorMessage {
                        errorBanner(errorMessage)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }

            bottomActions
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
        }
        .background(Color.dpBg.ignoresSafeArea())
        .onAppear {
            home.refreshLocationState()
            updateMapPosition()
        }
    }

    private var topBar: some View {
        HStack {
            Text("Step \(step.rawValue.formatted(.number.precision(.integerLength(2)))) / 04")
                .dpEyebrow()
            Spacer()
            if step != .done {
                Button("Skip") {
                    completeSetup()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.dpInk2)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow)
                .dpEyebrow()
            Text(title)
                .font(.system(size: 42, weight: .bold, design: .serif))
                .italic()
                .lineSpacing(-5)
                .foregroundStyle(Color.dpInk)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.dpInk2)
                .lineSpacing(4)
        }
        .padding(.top, DPSpacing.sm)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .intro:
            introRows
        case .home:
            homeStep
        case .loadout:
            templateGrid
        case .done:
            recapCard
        }
    }

    private var introRows: some View {
        VStack(spacing: 10) {
            setupRow(number: "01", icon: "house.fill", title: "Home location", subtitle: "For walk-out nudges")
            setupRow(number: "02", icon: "backpack.fill", title: "A loadout", subtitle: "School, gym, work...")
            setupRow(number: "03", icon: "square.grid.2x2.fill", title: "Your items", subtitle: "Things you bring")
        }
    }

    private var homeStep: some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            Map(position: $mapPosition) {
                if let coordinate = home.currentLocation?.coordinate {
                    Annotation("You", coordinate: coordinate) {
                        mapMarker(title: "YOU", symbol: "location.fill", tint: Color.dpBlue)
                    }
                }

                if let coordinate = home.homeCoordinate {
                    Annotation("Home", coordinate: coordinate) {
                        mapMarker(title: "HOME", symbol: "house.fill", tint: Color.dpOrange)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                    .stroke(Color.dpDivider, lineWidth: 1)
            )

            DPCard {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Selected")
                        .dpEyebrow()
                    Text(home.hasHomeLocation ? "Home location saved" : "Use your current location")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(Color.dpInk)
                    Text(homeLocationSubtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.dpInk3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var templateGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(templates) { template in
                Button {
                    selectedTemplateID = template.id
                } label: {
                    templateCard(template)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }

    private var recapCard: some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            Image(systemName: "checkmark")
                .font(.system(size: 46, weight: .black))
                .foregroundStyle(Color.dpInk)
                .frame(width: 96, height: 96)
                .background(Circle().fill(Color.dpOrange))
                .shadow(color: Color.dpOrange.opacity(0.35), radius: 28, x: 0, y: 14)

            VStack(alignment: .leading, spacing: 10) {
                recapRow(icon: "house.fill", title: home.hasHomeLocation ? "Home ready" : "Home skipped", subtitle: "home location")
                recapRow(icon: selectedTemplate.symbol, title: "\(createdLoadoutName) loadout", subtitle: "\(selectedTemplate.items.count) items ready")
                recapRow(icon: "bell.fill", title: "Walk-out nudges", subtitle: "enabled in settings")
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                    .fill(Color.dpInk)
            )
        }
    }

    private var bottomActions: some View {
        VStack(spacing: 10) {
            PrimaryButton(
                title: primaryTitle,
                icon: "arrow.right",
                isLoading: isCreating,
                isDisabled: isCreating
            ) {
                Task { await advance() }
            }

            if step == .home {
                SecondaryButton(title: "Use current location", variant: .ghost) {
                    useCurrentLocationForHome()
                }
            }
        }
    }

    private func mapMarker(title: String, symbol: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .black))
                Text(title)
                    .font(.system(size: 10.5, weight: .black))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Capsule().fill(Color.dpInk))

            Circle()
                .fill(tint)
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(Color.dpInk, lineWidth: 4))
        }
    }

    private func setupRow(number: String, icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: DPSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.dpOrange)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.dpInk)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Color.dpInk)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(Color.dpInk3)
            }
            Spacer()
            Text(number)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.dpInk4)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                .fill(Color.dpSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                        .stroke(Color.dpDivider, lineWidth: 1)
                )
        )
    }

    private func templateCard(_ template: StarterTemplate) -> some View {
        let isSelected = template.id == selectedTemplateID
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: template.symbol)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? Color.dpInk : Color.dpInk2)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(isSelected ? Color.dpOrange : Color.dpSurfaceAlt)
                    )
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(Color.dpInk)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.dpOrange))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.system(size: 16, weight: .black))
                Text(template.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? Color.dpInk4 : Color.dpInk3)
                Text("\(template.items.count) items")
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(isSelected ? Color.dpOrange : Color.dpInk4)
                    .padding(.top, 4)
            }
        }
        .foregroundStyle(isSelected ? Color.dpBg : Color.dpInk)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isSelected ? Color.dpInk : Color.dpSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.dpInk : Color.dpDivider, lineWidth: 1.4)
        )
    }

    private func recapRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.dpOrange)
                .frame(width: 20)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.dpBg)
            Text("· \(subtitle)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.dpInk4)
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Color.dpOrange)
        }
    }

    private func errorBanner(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.dpRed)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                    .fill(Color.dpRedSoft)
            )
    }

    private var eyebrow: String {
        switch step {
        case .intro: return "Welcome"
        case .home: return "Where do you leave from?"
        case .loadout: return "Start with a template"
        case .done: return "Step 04 / 04 · Done"
        }
    }

    private var title: String {
        switch step {
        case .intro: return "Let's build your\nfirst loadout."
        case .home: return "Set your home."
        case .loadout: return "What kind\nof day?"
        case .done: return "You're all set,\nlet's pack."
        }
    }

    private var message: String {
        switch step {
        case .intro: return "Three quick steps: where you live, what kind of day you're packing for, and the things you carry."
        case .home: return "Your home location powers walk-out nudges. You can skip this and set it later in Settings."
        case .loadout: return "Choose a starter pack. DayPack will create it in your backend account."
        case .done: return "Your starter loadout is ready. We'll suggest more as you use it."
        }
    }

    private var primaryTitle: String {
        switch step {
        case .intro: return "Let's go"
        case .home: return home.hasHomeLocation ? "Continue" : "Skip for now"
        case .loadout: return "Continue with \(selectedTemplate.name)"
        case .done: return "Open Today"
        }
    }

    private var homeLocationSubtitle: String {
        if let coordinate = home.homeCoordinate {
            let latitude = coordinate.latitude.formatted(.number.precision(.fractionLength(4)))
            let longitude = coordinate.longitude.formatted(.number.precision(.fractionLength(4)))
            return "\(latitude), \(longitude) · 50m radius"
        }
        if let error = home.lastError {
            return error
        }
        return "Tap Use current location while you are at home."
    }

    private func advance() async {
        errorMessage = nil
        switch step {
        case .intro:
            step = .home
        case .home:
            step = .loadout
        case .loadout:
            await createStarterPack()
            if errorMessage == nil {
                step = .done
            }
        case .done:
            completeSetup()
        }
    }

    private func useCurrentLocationForHome() {
        home.requestPermissions()
        home.useCurrentLocationAsHome()
        home.refreshLocationState()
        updateMapPosition()

        Task {
            try? await Task.sleep(for: .seconds(1))
            home.refreshLocationState()
            updateMapPosition()
        }
    }

    private func updateMapPosition() {
        let coordinate = home.homeCoordinate
            ?? home.currentLocation?.coordinate
            ?? CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
        mapPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private func createStarterPack() async {
        isCreating = true
        defer { isCreating = false }
        do {
            let loadout = try await loadoutService.createLoadout(
                name: selectedTemplate.name,
                symbol: selectedTemplate.symbol,
                tint: selectedTemplate.tint,
                schedule: selectedTemplate.schedule,
                items: selectedTemplate.items,
                isTemporary: false,
                alertTime: nil,
                returnAlertTime: nil
            )
            createdLoadoutName = loadout.name
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func completeSetup() {
        hasCompletedSetup = true
        if let userID = session.currentUser?.id {
            UserDefaults.standard.set(true, forKey: "hasCompletedSetup.\(userID.uuidString)")
        }
        setupRevision += 1
    }
}
