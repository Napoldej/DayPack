import SwiftUI

struct SectionHeader: View {
    let title: String
    var eyebrow: String? = nil
    var trailingTitle: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let eyebrow {
                Text(eyebrow).dpEyebrow()
            }
            HStack(alignment: .firstTextBaseline) {
                Text(title).dpTitle2()
                Spacer(minLength: 8)
                if let trailingTitle, let trailingAction {
                    Button(action: trailingAction) {
                        Text(trailingTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.dpOrange)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("SectionHeader") {
    VStack(alignment: .leading, spacing: 24) {
        SectionHeader(title: "Today's Loadout", eyebrow: "Active")
        SectionHeader(title: "Essentials")
        SectionHeader(title: "Loadouts", trailingTitle: "See all", trailingAction: {})
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
