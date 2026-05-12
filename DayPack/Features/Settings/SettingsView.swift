import CoreLocation
import MapKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.authSession) private var session
    @Environment(\.loadoutService) private var loadoutService
    @Environment(\.homeLocationService) private var homeLocationService

    @AppStorage("walkOutReminder") private var walkOutReminder: Bool = true

    @State private var showLogoutConfirm = false
    @State private var showDeleteAccountConfirm = false
    @State private var editName = ""
    @State private var editEmail = ""
    @State private var homeStatus = "Not set"
    @State private var permissionStatus = "Not requested"
    @State private var showHomeMap = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    settingsHeader
                        .padding(.top, DPSpacing.md)

                    profileCard

                    section(title: "Reminders", eyebrow: "Notifications") {
                        ToggleRow(
                            title: "Walk-out reminder",
                            subtitle: "Local alerts at each loadout's departure time",
                            isOn: $walkOutReminder
                        )
                        .onChange(of: walkOutReminder) { _, _ in
                            Task { await refreshNotifications() }
                        }
                    }

                    section(title: "Home Location", eyebrow: "Geofence") {
                        infoRow(title: "Permission", value: permissionStatus)
                        homeLocationRow
                    }

                    section(title: "History", eyebrow: "Backend") {
                        NavigationLink {
                            CheckHistoryView()
                        } label: {
                            HStack {
                                Text("Check sessions").font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Image(systemName: "clock.arrow.circlepath").font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(Color.dpInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                                    .fill(Color.dpSurface)
                            )
                        }
                    }

                    if let user = session.currentUser {
                        section(title: "Account", eyebrow: "Signed in") {
                            CustomTextField(label: "Name", text: $editName, placeholder: user.name)
                            CustomTextField(
                                label: "Email",
                                text: $editEmail,
                                placeholder: user.email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .never,
                                disableAutocorrection: true
                            )
                            HStack(spacing: DPSpacing.sm) {
                                SecondaryButton(
                                    title: "Save",
                                    icon: "checkmark",
                                    size: .md
                                ) {
                                    Task { await session.updateAccount(name: editName, email: editEmail) }
                                }
                                SecondaryButton(
                                    title: "Delete",
                                    icon: "trash",
                                    variant: .danger,
                                    size: .md
                                ) {
                                    showDeleteAccountConfirm = true
                                }
                            }
                        }
                    }

                    section(title: "About", eyebrow: "DayPack v0.1") {
                        infoRow(title: "Version", value: "0.1.0")
                        infoRow(title: "Made by", value: "Student Team 2026")

                        Button {
                            showLogoutConfirm = true
                        } label: {
                            HStack {
                                Text("Log out").font(.system(size: 15, weight: .semibold))
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(Color.dpRed)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                                    .fill(Color.dpSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, 116)
            }
            .background(Color.dpBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .sheet(isPresented: $showHomeMap, onDismiss: refreshHomeStatus) {
                HomeLocationMapSheet {
                    refreshHomeStatus()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .alert("Log out?", isPresented: $showLogoutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Log out", role: .destructive) { session.logout() }
            } message: {
                Text("You'll need to sign in again to see your loadouts.")
            }
            .alert("Delete account?", isPresented: $showDeleteAccountConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await session.deleteAccount() }
                }
            } message: {
                Text("This removes your backend account and signs you out.")
            }
            .onAppear {
                editName = session.currentUser?.name ?? ""
                editEmail = session.currentUser?.email ?? ""
                refreshHomeStatus()
            }
        }
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Settings")
                        .dpEyebrow()
                    Text("Preferences.")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .italic()
                        .foregroundStyle(Color.dpInk)
                }
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.dpInk)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.dpOrange))
            }

            Text("Tune the stuff DayPack needs before you leave: reminders, home, account, and history.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.dpInk3)
                .lineSpacing(3)
        }
    }

    private var profileCard: some View {
        HStack(spacing: DPSpacing.md) {
            Text(session.currentUser?.name.prefix(1).uppercased() ?? "D")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.dpInk)
                .frame(width: 54, height: 54)
                .background(Circle().fill(Color.dpOrange))
            VStack(alignment: .leading, spacing: 4) {
                Text(session.currentUser?.name ?? "DayPack")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Color.dpBg)
                Text(session.currentUser?.email ?? "Signed in")
                    .font(.system(size: 10.5, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.dpInk4)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .fill(Color.dpInk)
        )
    }

    private var homeLocationRow: some View {
        Button {
            showHomeMap = true
        } label: {
            HStack(spacing: DPSpacing.md) {
                Image(systemName: homeLocationService.hasHomeLocation ? "house.fill" : "map.fill")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Color.dpInk)
                    .frame(width: 42, height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                            .fill(Color.dpOrange)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("Home")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.dpInk)
                    Text(homeStatus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                        .lineLimit(2)
                }

                Spacer(minLength: DPSpacing.sm)

                HStack(spacing: 6) {
                    Text("Map")
                        .font(.system(size: 12, weight: .black))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .black))
                }
                .foregroundStyle(Color.dpInk)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .fill(Color.dpSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .stroke(Color.dpDivider, lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        eyebrow: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                if let eyebrow {
                    Text(eyebrow).dpEyebrow()
                }
                Text(title)
                    .font(.system(size: 23, weight: .black, design: .serif))
                    .italic()
                    .foregroundStyle(Color.dpInk)
            }
            VStack(spacing: DPSpacing.sm) {
                content()
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.dpInk2)
            Spacer()
            Text(value).font(.system(size: 15, weight: .medium)).foregroundStyle(Color.dpInk3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                .fill(Color.dpSurface)
        )
    }

    private func refreshNotifications() async {
        do {
            let loadouts = try await loadoutService.allLoadouts()
            try await NotificationScheduler.sync(loadouts: loadouts)
        } catch {
            // Silent — gating + scheduling failures are not user-actionable.
        }
    }

    private func refreshHomeStatus() {
        permissionStatus = switch homeLocationService.authorizationStatus {
        case .authorizedAlways:
            "Always"
        case .authorizedWhenInUse:
            "While Using"
        case .denied, .restricted:
            "Denied"
        case .notDetermined:
            "Not requested"
        @unknown default:
            "Unknown"
        }

        if let coordinate = homeLocationService.homeCoordinate {
            let latitude = coordinate.latitude.formatted(.number.precision(.fractionLength(4)))
            let longitude = coordinate.longitude.formatted(.number.precision(.fractionLength(4)))
            homeStatus = "\(latitude), \(longitude)"
        } else if let error = homeLocationService.lastError {
            homeStatus = error
        } else {
            homeStatus = "Not set"
        }
    }
}

private struct HomeLocationMapSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.homeLocationService) private var home

    var onChange: () -> Void

    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            sheetTopBar

            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Home Location")
                            .dpEyebrow()
                        Text("Set your home.")
                            .font(.system(size: 42, weight: .bold, design: .serif))
                            .italic()
                            .foregroundStyle(Color.dpInk)
                        Text("Drag the map to inspect your area, tap anywhere to pin home, or use your current location.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.dpInk3)
                            .lineSpacing(3)
                    }

                    mapCard
                    selectedCard
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

    private var sheetTopBar: some View {
        HStack {
            Text("Geofence")
                .dpEyebrow()
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color.dpInk)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.dpSurface))
                    .overlay(Circle().stroke(Color.dpDivider, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var mapCard: some View {
        MapReader { proxy in
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

                    MapCircle(center: coordinate, radius: 150)
                        .foregroundStyle(Color.dpOrange.opacity(0.18))
                        .stroke(Color.dpOrange, lineWidth: 2)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
            .onTapGesture { point in
                if let coordinate = proxy.convert(point, from: .local) {
                    home.setHome(coordinate)
                    updateMapPosition(center: coordinate)
                    onChange()
                }
            }
        }
        .frame(height: 340)
        .clipShape(RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .stroke(Color.dpDivider, lineWidth: 1)
        )
    }

    private var selectedCard: some View {
        HStack(spacing: DPSpacing.md) {
            Image(systemName: home.hasHomeLocation ? "house.fill" : "location.slash.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.dpInk)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                        .fill(home.hasHomeLocation ? Color.dpOrange : Color.dpSurfaceAlt)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(home.hasHomeLocation ? "Home location saved" : "No home set")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Color.dpInk)
                Text(homeLocationSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.dpInk3)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .fill(Color.dpSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .stroke(Color.dpDivider, lineWidth: 1)
        )
    }

    private var bottomActions: some View {
        VStack(spacing: 10) {
            PrimaryButton(title: "Use Current Location", icon: "scope") {
                useCurrentLocationForHome()
            }

            HStack(spacing: 10) {
                SecondaryButton(title: "Allow", icon: "location.fill", size: .md) {
                    home.requestPermissions()
                    home.refreshLocationState()
                    updateMapPosition()
                    onChange()
                }

                SecondaryButton(
                    title: home.hasHomeLocation ? "Clear" : "Done",
                    icon: home.hasHomeLocation ? "xmark.circle" : "checkmark",
                    variant: home.hasHomeLocation ? .danger : .ghost,
                    size: .md
                ) {
                    if home.hasHomeLocation {
                        home.clearHome()
                        updateMapPosition()
                        onChange()
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .background(Color.dpBg)
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

    private var homeLocationSubtitle: String {
        if let coordinate = home.homeCoordinate {
            let latitude = coordinate.latitude.formatted(.number.precision(.fractionLength(4)))
            let longitude = coordinate.longitude.formatted(.number.precision(.fractionLength(4)))
            return "\(latitude), \(longitude) · 150m radius"
        }
        if let error = home.lastError {
            return error
        }
        return "Tap the map or use current location while you are at home."
    }

    private func useCurrentLocationForHome() {
        home.requestPermissions()
        home.useCurrentLocationAsHome()
        home.refreshLocationState()
        updateMapPosition()
        onChange()

        Task {
            try? await Task.sleep(for: .seconds(1))
            home.refreshLocationState()
            updateMapPosition()
            onChange()
        }
    }

    private func updateMapPosition(center: CLLocationCoordinate2D? = nil) {
        let coordinate = center
            ?? home.homeCoordinate
            ?? home.currentLocation?.coordinate
            ?? CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
        mapPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }
}

#Preview {
    SettingsView()
}
