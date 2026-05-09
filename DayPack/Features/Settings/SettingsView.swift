import SwiftUI

struct SettingsView: View {
    @Environment(\.authSession) private var session

    @AppStorage("walkOutReminder") private var walkOutReminder: Bool = true
    @AppStorage("forgotNudge")     private var forgotNudge: Bool = true
    @AppStorage("highPriorityHL")  private var highPriorityHL: Bool = true
    @AppStorage("recurringHints")  private var recurringHints: Bool = true

    @State private var showLogoutConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    section(title: "Reminders", eyebrow: "Notifications") {
                        ToggleRow(
                            title: "Walk-out reminder",
                            subtitle: "5:30 PM at Home",
                            isOn: $walkOutReminder
                        )
                        ToggleRow(
                            title: "Forgot-something nudge",
                            subtitle: "Alert when leaving with unpacked items",
                            isOn: $forgotNudge
                        )
                    }

                    section(title: "Items", eyebrow: "Behavior") {
                        ToggleRow(
                            title: "High-priority highlighting",
                            subtitle: "Flag don't-forget items in red",
                            isOn: $highPriorityHL
                        )
                        ToggleRow(
                            title: "Recurring suggestions",
                            subtitle: "Suggest items based on your day",
                            isOn: $recurringHints
                        )
                    }

                    if let user = session.currentUser {
                        section(title: "Account", eyebrow: "Signed in") {
                            infoRow(title: "Name",  value: user.name)
                            infoRow(title: "Email", value: user.email)
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
}

#Preview {
    SettingsView()
}
