import SwiftUI

struct CustomTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.dpInk3)
                }
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.dpInk3)
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 17, weight: .semibold))
                .tracking(-0.2)
                .foregroundStyle(Color.dpInk)
                .focused($isFocused)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                .fill(Color.dpSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                .stroke(isFocused ? Color.dpOrange : .clear, lineWidth: 2)
        )
        .dpShadow(.soft)
    }
}

#Preview("CustomTextField") {
    @Previewable @State var name: String = "Water Bottle"
    @Previewable @State var note: String = ""
    return VStack(spacing: 16) {
        CustomTextField(label: "Item name", text: $name, placeholder: "Enter name")
        CustomTextField(label: "Note", text: $note, placeholder: "Optional", icon: "pencil")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
