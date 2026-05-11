import SwiftUI

struct SharingView: View {
    @Environment(\.apiClient) private var api
    @Environment(\.authSession) private var session
    @Environment(\.loadoutService) private var loadoutService

    @State private var loadouts: [Loadout] = []
    @State private var selectedLoadoutID: UUID?
    @State private var generatedCode: String?
    @State private var importCode = ""
    @State private var preview: ShareCodePreview?
    @State private var statusMessage: String?
    @State private var errorMessage: String?

    private var selectedLoadout: Loadout? {
        loadouts.first { $0.id == selectedLoadoutID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DPSpacing.lg) {
                SectionHeader(title: "Share Pack", eyebrow: "Code")
                shareForm

                if let generatedCode {
                    codeCard(generatedCode)
                }

                SectionHeader(title: "Import Pack", eyebrow: "Friend code")
                importForm

                if let preview {
                    previewCard(preview)
                }

                if let statusMessage {
                    messageRow(statusMessage, color: Color.dpGreen)
                }

                if let errorMessage {
                    messageRow(errorMessage, color: Color.dpRed)
                }
            }
            .padding(.horizontal, DPSpacing.lg)
            .padding(.bottom, DPSpacing.xxl)
        }
        .background(Color.dpBg)
        .navigationTitle("Share Packs")
        .toolbarBackground(Color.dpBg, for: .navigationBar)
        .task { await refreshLoadouts() }
    }

    private var shareForm: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                Picker("Loadout", selection: Binding(
                    get: { selectedLoadoutID },
                    set: { selectedLoadoutID = $0 }
                )) {
                    Text("Choose loadout").tag(Optional<UUID>.none)
                    ForEach(loadouts) { loadout in
                        Text(loadout.name).tag(Optional(loadout.id))
                    }
                }

                SecondaryButton(title: "Generate Code", icon: "link", size: .md) {
                    Task { await generateCode() }
                }
            }
        }
    }

    private func codeCard(_ code: String) -> some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                Text(code)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(Color.dpInk)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .center)

                if let selectedLoadout {
                    Text(selectedLoadout.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                HStack(spacing: DPSpacing.sm) {
                    SecondaryButton(title: "Copy", icon: "doc.on.doc", size: .md) {
                        UIPasteboard.general.string = code
                        statusMessage = "Code copied"
                    }
                    ShareLink(item: "Import my DayPack loadout with code \(code)") {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dpInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurfaceAlt))
                    }
                }
            }
        }
    }

    private var importForm: some View {
        DPCard {
            VStack(spacing: DPSpacing.md) {
                CustomTextField(
                    label: "Code",
                    text: $importCode,
                    placeholder: "PACK-7K2P",
                    autocapitalization: .characters,
                    disableAutocorrection: true
                )
                HStack(spacing: DPSpacing.sm) {
                    SecondaryButton(title: "Preview", icon: "eye", size: .md) {
                        Task { await previewCode() }
                    }
                    SecondaryButton(title: "Import", icon: "tray.and.arrow.down.fill", size: .md) {
                        Task { await importPack() }
                    }
                }
            }
        }
    }

    private func previewCard(_ preview: ShareCodePreview) -> some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.sm) {
                Text(preview.loadout.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.dpInk)
                Text("\(preview.loadout.items.count) items")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.dpInk3)
            }
        }
    }

    private func refreshLoadouts() async {
        do {
            loadouts = try await loadoutService.allLoadouts()
            selectedLoadoutID = selectedLoadoutID ?? loadouts.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func generateCode() async {
        guard let userID = session.currentUser?.id, let selectedLoadoutID else { return }
        clearMessages()
        do {
            let response: ShareCodeResponse = try await api.post(
                "/share-codes",
                body: ShareCodeCreateBody(loadoutID: selectedLoadoutID),
                query: [URLQueryItem(name: "userID", value: userID.uuidString)]
            )
            generatedCode = response.code
            statusMessage = "Code ready"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func previewCode() async {
        clearMessages()
        do {
            preview = try await api.get("/share-codes/\(normalizedImportCode())")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importPack() async {
        guard let userID = session.currentUser?.id else { return }
        clearMessages()
        do {
            let _: SharingLoadoutDTO = try await api.post(
                "/share-codes/\(normalizedImportCode())/import",
                body: EmptyBody(),
                query: [URLQueryItem(name: "userID", value: userID.uuidString)]
            )
            statusMessage = "Pack imported"
            importCode = ""
            preview = nil
            await refreshLoadouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func normalizedImportCode() -> String {
        importCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private func clearMessages() {
        statusMessage = nil
        errorMessage = nil
    }

    private func messageRow(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurface))
    }
}

private struct ShareCodeCreateBody: Encodable {
    let loadoutID: UUID
}

private struct ShareCodeResponse: Decodable {
    let code: String
}

private struct ShareCodePreview: Decodable {
    let code: String
    let loadout: SharingLoadoutDTO
}

private struct EmptyBody: Encodable {}

private struct SharingLoadoutDTO: Decodable {
    let id: UUID
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?
    let items: [SharingItemDTO]
}

private struct SharingItemDTO: Decodable {
    let id: UUID
    let name: String
    let isRecurring: Bool
    let order: Int
}
