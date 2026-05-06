import SwiftUI

struct DPCard<Content: View>: View {
    var padding: CGFloat = DPSpacing.lg
    var radius: CGFloat = DPRadius.xl
    var shadow: DPShadowStyle = .soft
    var background: Color = .dpSurface
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(background)
            )
            .dpShadow(shadow)
    }
}

#Preview("DPCard") {
    VStack(spacing: 16) {
        DPCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's loadout").dpEyebrow()
                Text("School Day").dpTitle2()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        DPCard(shadow: .card) {
            Text("Card shadow").dpHeadline()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
