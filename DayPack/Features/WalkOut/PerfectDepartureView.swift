import SwiftUI

struct PerfectDepartureView: View {
    let packedCount: Int
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: DPSpacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DPSpacing.lg) {
                Text("Perfect departure")
                    .font(.system(size: 11, weight: .bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.dpInk4)
                Text("You're\ngood to go.")
                    .font(.system(size: 62, weight: .bold, design: .serif))
                    .italic()
                    .lineSpacing(-8)
                    .foregroundStyle(Color.dpBg)
                Text("\(packedCount) items packed. Nothing is standing between you and the door.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.dpInk4)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: DPSpacing.md) {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.dpInk)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Color.dpOrange))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Packed and checked")
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(Color.dpBg)
                    Text("\(packedCount) items are ready for today.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.dpInk4)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                    .fill(Color.dpBg.opacity(0.06))
            )

            Spacer()
            Button(action: onDone) {
                HStack {
                    Text("Back to Today")
                        .font(.system(size: 16, weight: .black))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .black))
                }
                .foregroundStyle(Color.dpInk)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Capsule().fill(Color.dpOrange))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpInk.ignoresSafeArea())
    }
}
