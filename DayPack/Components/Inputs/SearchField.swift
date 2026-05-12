import SwiftUI

struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.dpInk4)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(Color.dpInk)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.dpInk4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.dpSurface)
        )
        .overlay(
            Capsule()
                .stroke(Color.dpDivider, lineWidth: 1)
        )
    }
}

#Preview("SearchField") {
    @Previewable @State var query: String = ""
    @Previewable @State var filled: String = "Water"
    return VStack(spacing: 16) {
        SearchField(text: $query, placeholder: "Search loadouts & items")
        SearchField(text: $filled, placeholder: "Search")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
