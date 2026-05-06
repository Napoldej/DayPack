import SwiftUI

extension Font {
    static let dpDisplay  = Font.system(size: 56, weight: .heavy,    design: .rounded)
    static let dpTitle1   = Font.system(size: 32, weight: .bold,     design: .rounded)
    static let dpTitle2   = Font.system(size: 22, weight: .bold,     design: .rounded)
    static let dpHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let dpBody     = Font.system(size: 16, weight: .medium,   design: .default)
    static let dpSubhead  = Font.system(size: 14, weight: .medium,   design: .default)
    static let dpCaption  = Font.system(size: 12, weight: .medium,   design: .default)
    static let dpEyebrow  = Font.system(size: 12, weight: .bold,     design: .default)
}

struct DPTrackedFont: ViewModifier {
    let font: Font
    let tracking: CGFloat
    func body(content: Content) -> some View {
        content.font(font).tracking(tracking)
    }
}

extension View {
    func dpDisplay()  -> some View { modifier(DPTrackedFont(font: .dpDisplay,  tracking: -1.6)) }
    func dpTitle1()   -> some View { modifier(DPTrackedFont(font: .dpTitle1,   tracking: -0.8)) }
    func dpTitle2()   -> some View { modifier(DPTrackedFont(font: .dpTitle2,   tracking: -0.4)) }
    func dpHeadline() -> some View { modifier(DPTrackedFont(font: .dpHeadline, tracking: -0.2)) }
    func dpBody()     -> some View { modifier(DPTrackedFont(font: .dpBody,     tracking: -0.2)) }
    func dpSubhead()  -> some View { modifier(DPTrackedFont(font: .dpSubhead,  tracking:  0)) }
    func dpCaption()  -> some View { modifier(DPTrackedFont(font: .dpCaption,  tracking:  0)) }

    func dpEyebrow() -> some View {
        self.font(.dpEyebrow)
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(Color.dpOrange)
    }
}

#Preview("Type ramp") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("13").dpDisplay()
            Text("Pack with confidence").dpTitle1()
            Text("School Day").dpTitle2()
            Text("All clear — let's go").dpHeadline()
            Text("Water Bottle").dpBody()
            Text("6 items · Tue, Thu, Sat").dpSubhead().foregroundStyle(.secondary)
            Text("Forgot last Tuesday").dpCaption().foregroundStyle(.secondary)
            Text("Today's loadout").dpEyebrow()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    .background(Color.dpBg)
}
