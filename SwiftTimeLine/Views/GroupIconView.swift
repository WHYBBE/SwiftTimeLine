import SwiftUI

enum GroupIconPresets {
    static let symbols: [String] = [
        "calendar.day.timeline.left",
        "calendar",
        "clock",
        "star",
        "heart",
        "book",
        "briefcase",
        "airplane",
        "leaf",
        "chart.bar",
        "flag",
        "pin",
        "person.2",
        "lightbulb",
        "graduationcap",
        "gamecontroller",
        "cart",
        "house",
    ]
}

struct GroupIconView: View {
    var emoji: String?
    var symbol: String?
    var color: Color
    var size: CGFloat = 16

    private var hasEmoji: Bool {
        !(emoji ?? "").isEmpty
    }

    var body: some View {
        Group {
            if hasEmoji, let emoji {
                Text(emoji)
                    .font(.system(size: size))
            } else {
                Image(systemName: symbol ?? TimelineGroup.defaultSymbol)
                    .font(.system(size: size))
                    .foregroundStyle(color)
            }
        }
        .frame(width: size + 4, height: size + 4)
    }
}
