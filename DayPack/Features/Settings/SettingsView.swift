import CoreLocation
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
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
                        infoRow(title: "Home", value: homeStatus)
                        HStack(spacing: DPSpacing.sm) {
                            SecondaryButton(title: "Allow", icon: "location.fill", size: .md) {
                                homeLocationService.requestPermissions()
                                refreshHomeStatus()
                            }
                            SecondaryButton(title: "Use Current", icon: "scope", size: .md) {
                                homeLocationService.useCurrentLocationAsHome()
                                refreshHomeStatus()
                            }
                        }
                        if homeLocationService.hasHomeLocation {
                            SecondaryButton(title: "Clear Home", icon: "xmark.circle", variant: .danger, size: .md) {
                                homeLocationService.clearHome()
                                refreshHomeStatus()
                            }
                        }
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
                                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
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
                                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                                    .fill(Color.dpSurface)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("Settings")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
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

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        eyebrow: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: title, eyebrow: eyebrow)
            VStack(spacing: DPSpacing.sm) {
                content()
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 15))
            Spacer()
            Text(value).font(.system(size: 15)).foregroundStyle(Color.dpInk3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
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

#Preview {
    SettingsView()
}
