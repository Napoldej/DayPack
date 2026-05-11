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
    static let dpOrange      = Color(hex: 0xF26A3D)
    static let dpOrangeDeep  = Color(hex: 0xC94821)
    static let dpOrangeSoft  = Color(hex: 0xFCE8DF)
    static let dpOrangeMuted = Color(hex: 0xFFF6F1)

    static let dpGreen       = Color(hex: 0x1F9D7A)
    static let dpGreenSoft   = Color(hex: 0xE1F5EF)
    static let dpRed         = Color(hex: 0xE5484D)
    static let dpRedSoft     = Color(hex: 0xFFEBEC)
    static let dpAmber       = Color(hex: 0xC98312)
    static let dpAmberSoft   = Color(hex: 0xFFF1D7)
    static let dpBlue        = Color(hex: 0x2F6FED)
    static let dpBlueSoft    = Color(hex: 0xE8F0FF)
    static let dpTeal        = Color(hex: 0x158A9A)
    static let dpTealSoft    = Color(hex: 0xDFF4F6)

    static let dpBg          = Color(hex: 0xF5F7FA)
    static let dpBgGrouped   = Color(hex: 0xE9EEF5)
    static let dpSurface     = Color(hex: 0xFFFFFF)
    static let dpSurfaceAlt  = Color(hex: 0xF8FAFC)

    static let dpInk         = Color(hex: 0x172033)
    static let dpInk2        = Color(hex: 0x334155)
    static let dpInk3        = Color(hex: 0x64748B)
    static let dpInk4        = Color(hex: 0x94A3B8)
    static let dpHairline    = Color(hex: 0xCBD5E1)
    static let dpDivider     = Color(hex: 0xE2E8F0)
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
