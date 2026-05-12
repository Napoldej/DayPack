import SwiftUI

struct ProgressBar: View {
    enum Size {
        case sm, lg
        var height: CGFloat { self == .sm ? 6 : 8 }
    }

    var value: Double
    var size: Size = .lg
    var label: String? = nil
    var trailingLabel: String? = nil
    var fillColor: Color = .dpOrange
    var trackColor: Color = .dpDivider

    private var clamped: Double { max(0, min(1, value)) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if label != nil || trailingLabel != nil {
                HStack {
                    if let label {
                        Text(label).font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.dpInk2)
                    }
                    Spacer()
                    if let trailingLabel {
                        Text(trailingLabel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.dpInk2)
                    }
                }
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(trackColor)
                    Capsule()
                        .fill(fillColor)
                        .frame(width: geo.size.width * CGFloat(clamped))
                        .animation(.easeOut(duration: 0.22), value: clamped)
                }
            }
            .frame(height: size.height)
        }
    }
}

#Preview("ProgressBar") {
    VStack(spacing: 24) {
        ProgressBar(value: 0.5, size: .lg, label: "3 of 6 packed", trailingLabel: "50%")
        ProgressBar(value: 0.8, size: .sm, label: "Trip — Carry-on")
        ProgressBar(value: 1.0, size: .lg, fillColor: .dpGreen)
        ProgressBar(value: 0.0, size: .sm)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
