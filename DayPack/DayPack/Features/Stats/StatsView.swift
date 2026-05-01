import SwiftUI

struct StatsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: StatsViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vm = viewModel {
                    content(vm: vm)
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Stats")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = StatsViewModel(service: service)
            }
        }
    }

    @ViewBuilder
    private func content(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.lg) {
            streakHero(vm: vm)
            heatmapSection(vm: vm)
            perLoadoutSection(vm: vm)
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.bottom, DPSpacing.xxl)
    }

    private func streakHero(vm: StatsViewModel) -> some View {
        DPCard(padding: DPSpacing.lg, radius: DPRadius.xxl, shadow: .card, background: .clear) {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current streak").dpEyebrow().foregroundStyle(.white.opacity(0.85))
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("\(vm.streak)").dpDisplay()
                            Text("days").dpHeadline()
                        }
                        .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "flame.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white.opacity(0.95))
                }

                HStack(spacing: 8) {
                    ForEach(0..<vm.weekDots.count, id: \.self) { idx in
                        Circle()
                            .fill(vm.weekDots[idx] ? Color.white : Color.white.opacity(0.25))
                            .frame(width: 14, height: 14)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.dpOrange, Color.dpOrangeDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }

    private func heatmapSection(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Last 30 days", eyebrow: "Perfect days")
            DPCard {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                    spacing: 8
                ) {
                    ForEach(vm.heatmap) { stat in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color(for: stat.completion))
                            .frame(height: 24)
                    }
                }
            }
        }
    }

    private func perLoadoutSection(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "By loadout", eyebrow: "Completion")
            DPCard {
                VStack(spacing: DPSpacing.md) {
                    ForEach(vm.perLoadout) { row in
                        HStack(spacing: DPSpacing.md) {
                            IconTile(symbol: row.loadout.symbol, tint: row.loadout.tint, size: .sm)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(row.loadout.name).dpHeadline()
                                    Spacer()
                                    Text("\(Int(row.completion * 100))%")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(Color.dpOrange)
                                }
                                ProgressBar(value: row.completion, size: .sm)
                            }
                        }
                    }
                }
            }
        }
    }

    private func color(for completion: Double) -> Color {
        if completion >= 0.999 { return Color.dpOrange }
        if completion >= 0.66  { return Color.dpOrange.opacity(0.55) }
        if completion >= 0.33  { return Color.dpOrange.opacity(0.30) }
        if completion > 0      { return Color.dpOrange.opacity(0.15) }
        return Color.dpBgGrouped
    }
}

#Preview {
    StatsView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
