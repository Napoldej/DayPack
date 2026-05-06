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
                .shadow(color: Color.black.opacity(0.04), radius: 1,  x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)
        case .card:
            content
                .shadow(color: Color.black.opacity(0.05), radius: 1,  x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.07), radius: 16, x: 0, y: 12)
        case .pop:
            content
                .shadow(color: Color.black.opacity(0.08), radius: 6,  x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 24)
        case .brand:
            content
                .shadow(color: Color.dpOrange.opacity(0.30), radius: 8, x: 0, y: 6)
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
                .frame(height: 80)
                .overlay(Text(name).dpHeadline())
                .dpShadow(style)
                .padding(.horizontal)
        }
        RoundedRectangle(cornerRadius: DPRadius.lg)
            .fill(Color.dpOrange)
            .frame(height: 80)
            .overlay(Text("brand").dpHeadline().foregroundStyle(.white))
            .dpShadow(.brand)
            .padding(.horizontal)
    }
    .padding(.vertical, 40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
