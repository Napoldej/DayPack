import SwiftUI

enum DPShadowStyle {
    case soft, card, pop, brand
}

struct DPShadow: ViewModifier {
    let style: DPShadowStyle

    func body(content: Content) -> some View {
        switch style {
        case .soft:
            content
                .shadow(color: Color.dpInk.opacity(0.04), radius: 1, x: 0, y: 1)
                .shadow(color: Color.dpInk.opacity(0.04), radius: 8, x: 0, y: 5)
        case .card:
            content
                .shadow(color: Color.dpInk.opacity(0.05), radius: 1, x: 0, y: 1)
                .shadow(color: Color.dpInk.opacity(0.08), radius: 14, x: 0, y: 8)
        case .pop:
            content
                .shadow(color: Color.dpInk.opacity(0.10), radius: 4, x: 0, y: 3)
                .shadow(color: Color.dpInk.opacity(0.16), radius: 24, x: 0, y: 16)
        case .brand:
            content
                .shadow(color: Color.dpInk.opacity(0.20), radius: 16, x: 0, y: 10)
        }
    }
}

extension View {
    func dpShadow(_ style: DPShadowStyle = .soft) -> some View {
        modifier(DPShadow(style: style))
    }
}

#Preview("Shadows") {
    VStack(spacing: 24) {
        ForEach([("soft", DPShadowStyle.soft),
                 ("card", .card),
                 ("pop",  .pop)], id: \.0) { name, style in
            RoundedRectangle(cornerRadius: DPRadius.lg)
                .fill(Color.dpSurface)
                .frame(height: 72)
                .overlay(Text(name).dpHeadline())
                .dpShadow(style)
                .padding(.horizontal)
        }
        RoundedRectangle(cornerRadius: DPRadius.lg)
            .fill(Color.dpOrange)
            .frame(height: 72)
            .overlay(Text("brand").dpHeadline().foregroundStyle(.white))
            .dpShadow(.brand)
            .padding(.horizontal)
    }
    .padding(.vertical, 40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
