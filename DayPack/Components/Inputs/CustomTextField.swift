import SwiftUI

struct CustomTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .sentences
    var disableAutocorrection: Bool = false
    var hint: String? = nil

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
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.dpInk)
            .focused($isFocused)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(disableAutocorrection)

            if let hint {
                Text(hint)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dpInk3)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                .fill(Color.dpSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                .stroke(isFocused ? Color.dpInk : Color.dpDivider, lineWidth: 1.4)
        )
        .dpShadow(.soft)
    }
}

#Preview("CustomTextField") {
    @Previewable @State var name: String = "Water Bottle"
    @Previewable @State var note: String = ""
    @Previewable @State var password: String = ""
    return VStack(spacing: 16) {
        CustomTextField(label: "Item name", text: $name, placeholder: "Enter name")
        CustomTextField(label: "Note", text: $note, placeholder: "Optional", icon: "pencil")
        CustomTextField(
            label: "Password",
            text: $password,
            placeholder: "Required",
            isSecure: true,
            textContentType: .newPassword,
            hint: "8+ characters"
        )
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
