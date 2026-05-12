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
    // MARK: - DayPack v2 brand: lime accent, navy ink, cream paper
    static let dpOrange      = Color(hex: 0xEDF312)
    static let dpOrangeDeep  = Color(hex: 0xC9D100)
    static let dpOrangeSoft  = Color(hex: 0xF6FAC8)
    static let dpOrangeMuted = Color(hex: 0xFAFBD9)

    // MARK: - Semantic
    static let dpGreen       = Color(hex: 0x2F7D4C)
    static let dpGreenSoft   = Color(hex: 0xE3EFE8)
    static let dpRed         = Color(hex: 0xD24C3E)
    static let dpRedSoft     = Color(hex: 0xF7E1DE)
    static let dpAmber       = Color(hex: 0x8A7800)
    static let dpAmberSoft   = Color(hex: 0xF5F7BF)
    static let dpBlue        = Color(hex: 0x2D4EA8)
    static let dpBlueSoft    = Color(hex: 0xE1E6F6)
    static let dpTeal        = Color(hex: 0x3D3D2E)
    static let dpTealSoft    = Color(hex: 0xE8E8DE)

    // MARK: - Surfaces
    static let dpBg          = Color(hex: 0xF5F5F0)
    static let dpBgGrouped   = Color(hex: 0xECEBE3)
    static let dpSurface     = Color(hex: 0xFFFFFF)
    static let dpSurfaceAlt  = Color(hex: 0xECEBE3)

    // MARK: - Ink
    static let dpInk         = Color(hex: 0x1A1A2E)
    static let dpInk2        = Color(hex: 0x3D3D2E)
    static let dpInk3        = Color(hex: 0x7C7C70)
    static let dpInk4        = Color(hex: 0xB6B6AB)

    // MARK: - Dividers
    static let dpHairline    = Color(hex: 0xE5E4DA)
    static let dpDivider     = Color(hex: 0xD9D8CD)
}

#Preview("Color tokens") {
    ScrollView {
        let groups: [(String, [(String, Color)])] = [
            ("Brand", [
                ("dpOrange",      .dpOrange),
                ("dpOrangeDeep",  .dpOrangeDeep),
                ("dpOrangeSoft",  .dpOrangeSoft),
            ]),
            ("Semantic", [
                ("dpGreen",     .dpGreen),
                ("dpGreenSoft", .dpGreenSoft),
                ("dpRed",       .dpRed),
                ("dpRedSoft",   .dpRedSoft),
                ("dpAmber",     .dpAmber),
            ]),
            ("Surface", [
                ("dpBg",         .dpBg),
                ("dpBgGrouped",  .dpBgGrouped),
                ("dpSurface",    .dpSurface),
                ("dpSurfaceAlt", .dpSurfaceAlt),
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
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(pair.1)
                                    .frame(height: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.dpDivider, lineWidth: 0.5)
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
