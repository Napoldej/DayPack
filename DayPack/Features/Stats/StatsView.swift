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
            Task { await viewModel?.refresh() }
        }
    }

    @ViewBuilder
    private func content(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.lg) {
            streakHero(vm: vm)
            heatmapSection(vm: vm)
            perLoadoutSection(vm: vm)
        }
        .padding(.horizontal, DPSpacing.base)
        .padding(.bottom, DPSpacing.xxl)
    }

    private func streakHero(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current streak").dpEyebrow()
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(vm.streak)").dpDisplay()
                        Text("days").dpHeadline()
                    }
                    .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white.opacity(0.9))
            }

            HStack(spacing: 8) {
                ForEach(0..<vm.weekDots.count, id: \.self) { idx in
                    Circle()
                        .fill(vm.weekDots[idx] ? Color.white : Color.white.opacity(0.25))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding(DPSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.dpOrange, Color.dpOrangeDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
        .dpShadow(.brand)
    }

    private func heatmapSection(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Last 30 days", eyebrow: "Completion")
            DPCard {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                    spacing: 8
                ) {
                    ForEach(vm.heatmap) { stat in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(heatmapColor(for: stat.completion))
                            .frame(height: 24)
                    }
                }
            }
        }
    }

    private func perLoadoutSection(vm: StatsViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "By loadout", eyebrow: "Rates")
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
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.dpInk2)
                                }
                                ProgressBar(value: row.completion, size: .sm, fillColor: .dpOrange)
                            }
                        }
                    }
                }
            }
        }
    }

    private func heatmapColor(for completion: Double) -> Color {
        if completion >= 0.999 { return Color.dpOrange }
        if completion >= 0.66  { return Color.dpOrange.opacity(0.6) }
        if completion >= 0.33  { return Color.dpOrange.opacity(0.3) }
        if completion > 0      { return Color.dpOrange.opacity(0.15) }
        return Color.dpDivider
    }
}

#Preview {
    StatsView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
