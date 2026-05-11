import SwiftUI

struct WeekdaySelector: View {
    @Binding var selectedDays: Set<Int>

    private let days: [(id: Int, label: String)] = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat"),
    ]

    var body: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                Text("Schedule").dpEyebrow().foregroundStyle(Color.dpInk3)

                HStack(spacing: 6) {
                    ForEach(days, id: \.id) { day in
                        Button {
                            toggle(day.id)
                        } label: {
                            Text(day.label)
                                .font(.system(size: 12, weight: .bold))
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                                .foregroundStyle(selectedDays.contains(day.id) ? Color.white : Color.dpInk2)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: DPRadius.sm, style: .continuous)
                                        .fill(selectedDays.contains(day.id) ? Color.dpOrange : Color.dpSurfaceAlt)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func toggle(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

enum WeekdaySchedule {
    static func text(from selectedDays: Set<Int>) -> String {
        let names = [
            1: "Sun", 2: "Mon", 3: "Tue", 4: "Wed",
            5: "Thu", 6: "Fri", 7: "Sat",
        ]
        let days = selectedDays.sorted()
        guard !days.isEmpty else { return "Manual" }
        return days.compactMap { names[$0] }.joined(separator: " · ")
    }
}
