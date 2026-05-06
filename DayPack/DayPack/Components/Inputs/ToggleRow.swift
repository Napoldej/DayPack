import SwiftUI

struct ToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: DPSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.dpInk)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dpInk3)
                }
            }
            Spacer(minLength: DPSpacing.sm)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.dpOrange)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                .fill(Color.dpSurface)
        )
    }
}

#Preview("ToggleRow") {
    @Previewable @State var recurring = true
    @Previewable @State var reminder = true
    @Previewable @State var hi = false
    return VStack(spacing: 12) {
        ToggleRow(title: "Recurring", subtitle: "Repeats every gym day", isOn: $recurring)
        ToggleRow(title: "Walk-out reminder", subtitle: "5:30 PM at Home", isOn: $reminder)
        ToggleRow(title: "High priority", subtitle: "Highlight if forgotten", isOn: $hi)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
