import SwiftUI

struct IconTile: View {
    enum Size {
        case sm, md, lg

        var dimension: CGFloat {
            switch self {
            case .sm: return 32
            case .md: return 44
            case .lg: return 48
            }
        }

        var radius: CGFloat {
            switch self {
            case .sm: return 9
            case .md: return 12
            case .lg: return 14
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .sm: return 16
            case .md: return 20
            case .lg: return 24
            }
        }
    }

    let symbol: String
    var tint: ItemTint = .orange
    var size: Size = .sm

    var body: some View {
        RoundedRectangle(cornerRadius: size.radius, style: .continuous)
            .fill(tint.background)
            .frame(width: size.dimension, height: size.dimension)
            .overlay(
                Image(systemName: symbol)
                    .font(.system(size: size.iconSize, weight: .semibold))
                    .foregroundStyle(tint.foreground)
            )
    }
}

#Preview("IconTile") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            IconTile(symbol: "drop.fill", tint: .orange, size: .sm)
            IconTile(symbol: "drop.fill", tint: .orange, size: .md)
            IconTile(symbol: "drop.fill", tint: .orange, size: .lg)
        }
        HStack(spacing: 12) {
            IconTile(symbol: "book.closed.fill", tint: .green,  size: .md)
            IconTile(symbol: "dumbbell.fill",    tint: .purple, size: .md)
            IconTile(symbol: "paperplane.fill",  tint: .teal,   size: .md)
            IconTile(symbol: "exclamationmark.triangle.fill", tint: .red, size: .md)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
