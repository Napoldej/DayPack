import SwiftUI

struct LoadoutsView: View {
    @Environment(\.apiClient) private var api
    @Environment(\.authSession) private var session
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?
    @State private var showBuilder = false
    @State private var editingLoadout: Loadout?
    @State private var shareSheet: LoadoutShareSheet?
    @State private var shareError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.loadouts.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                symbol: "tray",
                                title: "No loadouts yet",
                                message: "Create your first loadout to get personalised packing reminders.",
                                ctaTitle: "Create a loadout",
                                ctaAction: { showBuilder = true }
                            )
                            .padding(.horizontal, DPSpacing.lg)
                        }
                    } else {
                        content(vm: vm)
                    }
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Loadouts")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBuilder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpOrange))
                    }
                }
            }
            .sheet(isPresented: $showBuilder, onDismiss: {
                Task { await viewModel?.refresh() }
            }) {
                if let vm = viewModel {
                    LoadoutBuilderView { name, symbol, tint, schedule, items, isTemporary, alertTime, returnAlertTime in
                        Task {
                            _ = await vm.createLoadout(
                                name: name,
                                symbol: symbol,
                                tint: tint,
                                schedule: schedule,
                                items: items,
                                isTemporary: isTemporary,
                                alertTime: alertTime,
                                returnAlertTime: returnAlertTime
                            )
                        }
                    }
                }
            }
            .sheet(item: $editingLoadout, onDismiss: {
                Task { await viewModel?.refresh() }
            }) { loadout in
                LoadoutEditorView(loadout: loadout) {
                    Task { await viewModel?.refresh() }
                }
            }
            .sheet(item: $shareSheet) { sheet in
                loadoutShareSheet(sheet)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoadoutsViewModel(service: service)
                Task { await viewModel?.refresh() }
            } else {
                Task { await viewModel?.refresh() }
            }
        }
    }

    @ViewBuilder
    private func content(vm: LoadoutsViewModel) -> some View {
        List {
            SearchField(
                text: Binding(
                    get: { vm.searchText },
                    set: { vm.searchText = $0 }
                ),
                placeholder: "Search loadouts & items"
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: DPSpacing.md, leading: DPSpacing.lg, bottom: DPSpacing.sm, trailing: DPSpacing.lg))
            .listRowBackground(Color.dpBg)

            ForEach(vm.filtered) { loadout in
                loadoutRow(loadout, vm: vm)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: DPSpacing.sm, leading: DPSpacing.lg, bottom: DPSpacing.sm, trailing: DPSpacing.lg))
                    .listRowBackground(Color.dpBg)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            Task { await vm.setToday(loadout) }
                        } label: {
                            Label("Today", systemImage: "checkmark.circle.fill")
                        }
                        .tint(Color.dpOrange)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await vm.deleteLoadout(loadout) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func loadoutRow(_ loadout: Loadout, vm: LoadoutsViewModel) -> some View {
        ZStack(alignment: .topTrailing) {
            LoadoutCard(
                loadout: loadout,
                itemCount: vm.itemCount(for: loadout),
                isActive: loadout.id == vm.todaysID,
                onTap: { Task { await vm.setToday(loadout) } }
            )

            Menu {
                Button {
                    editingLoadout = loadout
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button {
                    Task { await vm.setToday(loadout) }
                } label: {
                    Label("Use Today", systemImage: "checkmark.circle")
                }
                Button {
                    Task { await generateShareCode(for: loadout) }
                } label: {
                    Label("Share Code", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    Task { await vm.deleteLoadout(loadout) }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.dpInk2)
                    .frame(width: 30, height: 30)
                    .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurfaceAlt))
                    .overlay(
                        RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                            .stroke(Color.dpDivider, lineWidth: 1)
                    )
            }
            .menuStyle(.borderlessButton)
            .menuOrder(.fixed)
            .padding(10)
            .accessibilityLabel("Loadout actions")
        }
    }

    private func loadoutShareSheet(_ sheet: LoadoutShareSheet) -> some View {
        NavigationStack {
            VStack(spacing: DPSpacing.lg) {
                IconTile(symbol: sheet.loadout.symbol, tint: sheet.loadout.tint, size: .lg)
                VStack(spacing: DPSpacing.xs) {
                    Text(sheet.loadout.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.dpInk)
                    Text("Share this code with a friend")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                }

                Text(sheet.code)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(Color.dpInk)
                    .textSelection(.enabled)
                    .padding(.vertical, DPSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous).fill(Color.dpSurface))

                HStack(spacing: DPSpacing.sm) {
                    SecondaryButton(title: "Copy", icon: "doc.on.doc", size: .md) {
                        UIPasteboard.general.string = sheet.code
                    }
                    ShareLink(item: "Import my DayPack loadout with code \(sheet.code)") {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dpInk)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurfaceAlt))
                    }
                }

                Spacer()
            }
            .padding(DPSpacing.lg)
            .background(Color.dpBg.ignoresSafeArea())
            .navigationTitle("Share Pack")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func generateShareCode(for loadout: Loadout) async {
        guard let userID = session.currentUser?.id else { return }
        shareError = nil
        do {
            let response: LoadoutShareCodeResponse = try await api.post(
                "/share-codes",
                body: LoadoutShareCodeCreateBody(loadoutID: loadout.id),
                query: [URLQueryItem(name: "userID", value: userID.uuidString)]
            )
            shareSheet = LoadoutShareSheet(loadout: loadout, code: response.code)
        } catch {
            shareError = error.localizedDescription
        }
    }
}

private struct LoadoutShareSheet: Identifiable {
    let id = UUID()
    let loadout: Loadout
    let code: String
}

private struct LoadoutShareCodeCreateBody: Encodable {
    let loadoutID: UUID
}

private struct LoadoutShareCodeResponse: Decodable {
    let code: String
}

#Preview {
    LoadoutsView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
