import SwiftUI

struct PerfectDepartureView: View {
    let packedCount: Int
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: DPSpacing.xl) {
            Spacer()
            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? Color.dpOrange : Color.dpGreen)
                        .frame(width: 8, height: 24)
                        .offset(y: -86)
                        .rotationEffect(.degrees(Double(index) * 30))
                }
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 92, weight: .bold))
                    .foregroundStyle(Color.dpGreen)
            }

            VStack(spacing: DPSpacing.sm) {
                Text("Perfect Departure").dpTitle1()
                Text("\(packedCount) items packed. You are ready to go.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.dpInk3)
                    .multilineTextAlignment(.center)
            }

            DPCard {
                HStack {
                    Image(systemName: "flame.fill").foregroundStyle(Color.dpOrange)
                    Text("Streak updated after this check appears in history.")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                }
            }

            Spacer()

            PrimaryButton(title: "Done", icon: "checkmark", action: onDone)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBg.ignoresSafeArea())
    }
}
