import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >>  8) & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

extension Color {
    static let dpOrange      = Color(hex: 0xFF6B2C)
    static let dpOrangeDeep  = Color(hex: 0xE8531A)
    static let dpOrangeSoft  = Color(hex: 0xFFE9DC)
    static let dpOrangeMuted = Color(hex: 0xFFF4ED)

    static let dpGreen       = Color(hex: 0x2FBF71)
    static let dpGreenSoft   = Color(hex: 0xE5F7EC)
    static let dpRed         = Color(hex: 0xE5484D)
    static let dpRedSoft     = Color(hex: 0xFFEBEC)
    static let dpAmber       = Color(hex: 0xF5A524)
    static let dpAmberSoft   = Color(hex: 0xFFF3DC)

    static let dpBg          = Color(hex: 0xF7F5F2)
    static let dpBgGrouped   = Color(hex: 0xF2EFEA)
    static let dpSurface     = Color(hex: 0xFFFFFF)
    static let dpSurfaceAlt  = Color(hex: 0xFAF8F5)

    static let dpInk         = Color(hex: 0x1B1B1F)
    static let dpInk2        = Color(hex: 0x3C3C43)
    static let dpInk3        = Color(hex: 0x3C3C43, alpha: 0.6)
    static let dpInk4        = Color(hex: 0x3C3C43, alpha: 0.36)
    static let dpHairline    = Color(hex: 0x3C3C43, alpha: 0.10)
    static let dpDivider     = Color(hex: 0x3C3C43, alpha: 0.06)
}

#Preview("Color tokens") {
    ScrollView {
        let groups: [(String, [(String, Color)])] = [
            ("Brand", [
                ("dpOrange",      .dpOrange),
                ("dpOrangeDeep",  .dpOrangeDeep),
                ("dpOrangeSoft",  .dpOrangeSoft),
                ("dpOrangeMuted", .dpOrangeMuted),
            ]),
            ("Semantic", [
                ("dpGreen",     .dpGreen),
                ("dpGreenSoft", .dpGreenSoft),
                ("dpAmber",     .dpAmber),
                ("dpRed",       .dpRed),
            ]),
            ("Surface", [
                ("dpBg",        .dpBg),
                ("dpBgGrouped", .dpBgGrouped),
                ("dpSurface",   .dpSurface),
            ]),
            ("Ink", [
                ("dpInk",  .dpInk),
                ("dpInk2", .dpInk2),
                ("dpInk3", .dpInk3),
                ("dpInk4", .dpInk4),
            ]),
        ]

        VStack(alignment: .leading, spacing: 24) {
            ForEach(groups, id: \.0) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.0).font(.headline)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 12)], spacing: 12) {
                        ForEach(group.1, id: \.0) { pair in
                            VStack(alignment: .leading, spacing: 6) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(pair.1)
                                    .frame(height: 64)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.dpHairline, lineWidth: 0.5)
                                    )
                                Text(pair.0).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    .background(Color.dpBg)
}
