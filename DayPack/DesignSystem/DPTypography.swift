import SwiftUI

extension Font {
    static let dpDisplay  = Font.system(size: 42, weight: .black,    design: .serif)
    static let dpTitle1   = Font.system(size: 30, weight: .bold,     design: .serif)
    static let dpTitle2   = Font.system(size: 21, weight: .bold,     design: .default)
    static let dpHeadline = Font.system(size: 17, weight: .semibold, design: .default)
    static let dpBody     = Font.system(size: 15, weight: .regular,  design: .default)
    static let dpSubhead  = Font.system(size: 13, weight: .medium,   design: .default)
    static let dpCaption  = Font.system(size: 12, weight: .medium,   design: .default)
    static let dpEyebrow  = Font.system(size: 11, weight: .bold,     design: .default)
}

struct DPTrackedFont: ViewModifier {
    let font: Font
    let tracking: CGFloat
    func body(content: Content) -> some View {
        content.font(font).tracking(tracking)
    }
}

extension View {
    func dpDisplay()  -> some View { modifier(DPTrackedFont(font: .dpDisplay,  tracking: 0)) }
    func dpTitle1()   -> some View { modifier(DPTrackedFont(font: .dpTitle1,   tracking: 0)) }
    func dpTitle2()   -> some View { modifier(DPTrackedFont(font: .dpTitle2,   tracking: 0)) }
    func dpHeadline() -> some View { modifier(DPTrackedFont(font: .dpHeadline, tracking: 0)) }
    func dpBody()     -> some View { modifier(DPTrackedFont(font: .dpBody,     tracking: 0)) }
    func dpSubhead()  -> some View { modifier(DPTrackedFont(font: .dpSubhead,  tracking: 0)) }
    func dpCaption()  -> some View { modifier(DPTrackedFont(font: .dpCaption,  tracking: 0)) }

    func dpEyebrow() -> some View {
        self.font(.dpEyebrow)
            .tracking(0.2)
            .textCase(.uppercase)
            .foregroundStyle(Color.dpInk3)
    }
}

#Preview("Type ramp") {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("13").dpDisplay()
            Text("Today's Pack").dpTitle1()
            Text("Essentials").dpTitle2()
            Text("Water Bottle").dpHeadline()
            Text("A regular body description goes here.").dpBody().foregroundStyle(Color.dpInk2)
            Text("6 items · Tue, Thu, Sat").dpSubhead().foregroundStyle(Color.dpInk3)
            Text("Forgot last Tuesday").dpCaption().foregroundStyle(Color.dpInk3)
            Text("Active loadout").dpEyebrow()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    .background(Color.dpBg)
}
