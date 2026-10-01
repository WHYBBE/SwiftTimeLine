import SwiftUI

struct TagChip: View {
    let tag: Tag
    var isSelected: Bool = false
    var isActive: Bool = false
    var showDot: Bool = true

    var body: some View {
        let color = Color(hex: tag.color)
        HStack(spacing: 4) {
            if showDot {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            Text(tag.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(background(for: color))
        .foregroundStyle(foreground(for: color))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(
                (isSelected || isActive) ? color : Color.clear,
                lineWidth: 1
            )
        )
    }

    private func background(for color: Color) -> Color {
        if isSelected { return color.opacity(0.25) }
        if isActive { return color.opacity(0.3) }
        return Color.secondary.opacity(0.1)
    }

    private func foreground(for color: Color) -> Color {
        isActive ? color : (isSelected ? .primary : .secondary)
    }
}
