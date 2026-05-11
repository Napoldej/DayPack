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
    static let dpOrange      = Color(hex: 0xE76F3C)
    static let dpOrangeDeep  = Color(hex: 0xA84725)
    static let dpOrangeSoft  = Color(hex: 0xF7E5DA)
    static let dpOrangeMuted = Color(hex: 0xFBF3EF)

    static let dpGreen       = Color(hex: 0x4E8A68)
    static let dpGreenSoft   = Color(hex: 0xE8F1EA)
    static let dpRed         = Color(hex: 0xC94E45)
    static let dpRedSoft     = Color(hex: 0xF8E7E4)
    static let dpAmber       = Color(hex: 0xA8782B)
    static let dpAmberSoft   = Color(hex: 0xF5EBD8)
    static let dpBlue        = Color(hex: 0x4B6F9F)
    static let dpBlueSoft    = Color(hex: 0xE8EDF4)
    static let dpTeal        = Color(hex: 0x4E8582)
    static let dpTealSoft    = Color(hex: 0xE5F0EF)

    static let dpBg          = Color(hex: 0xF8F8F8)
    static let dpBgGrouped   = Color(hex: 0xEFEDEA)
    static let dpSurface     = Color(hex: 0xFFFFFF)
    static let dpSurfaceAlt  = Color(hex: 0xF4F3F1)

    static let dpInk         = Color(hex: 0x34322D)
    static let dpInk2        = Color(hex: 0x55514A)
    static let dpInk3        = Color(hex: 0x7A756C)
    static let dpInk4        = Color(hex: 0xA6A199)
    static let dpHairline    = Color(hex: 0xD8D4CE)
    static let dpDivider     = Color(hex: 0xE6E2DC)
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
