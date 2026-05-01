import SwiftUI

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var ctaTitle: String? = nil
    var ctaAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: DPSpacing.base) {
            ZStack {
                Circle().fill(Color.dpOrangeSoft).frame(width: 96, height: 96)
                Image(systemName: symbol)
                    .font(.system(size: 38, weight: .regular))
                    .foregroundStyle(Color.dpOrange)
            }
            Text(title).dpTitle2()
            Text(message)
                .dpSubhead()
                .foregroundStyle(Color.dpInk3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DPSpacing.lg)

            if let ctaTitle, let ctaAction {
                PrimaryButton(title: ctaTitle, action: ctaAction)
                    .padding(.top, DPSpacing.sm)
                    .padding(.horizontal, DPSpacing.xxl)
            }
        }
        .padding(.vertical, DPSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview("EmptyStateView") {
    EmptyStateView(
        symbol: "tray",
        title: "No loadouts yet",
        message: "Create your first loadout to get personalised packing reminders.",
        ctaTitle: "Create a loadout",
        ctaAction: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
