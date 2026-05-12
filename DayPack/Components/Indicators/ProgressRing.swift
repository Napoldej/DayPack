import SwiftUI

struct ProgressRing: View {
    var value: Double
    var size: CGFloat = 64
    var lineWidth: CGFloat = 6
    var trackColor: Color = Color.dpDivider
    var fillColor: Color = .dpOrange
    var label: String? = nil

    private var clamped: Double { max(0, min(1, value)) }

    var body: some View {
        ZStack {
            Circle().stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(clamped))
                .stroke(fillColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.22), value: clamped)

            if let label {
                Text(label)
                    .font(.system(size: size * 0.22, weight: .bold))
                    .foregroundStyle(Color.dpInk)
            } else {
                Text("\(Int(clamped * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold))
                    .foregroundStyle(Color.dpInk)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview("ProgressRing") {
    VStack(spacing: 24) {
        HStack(spacing: 24) {
            ProgressRing(value: 0.0)
            ProgressRing(value: 0.33)
            ProgressRing(value: 0.63)
            ProgressRing(value: 1.0, fillColor: .dpGreen)
        }
        ProgressRing(value: 0.66, size: 120, lineWidth: 10, label: "4 / 6")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
