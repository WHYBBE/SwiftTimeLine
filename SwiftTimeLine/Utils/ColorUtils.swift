import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

let presetColors: [(name: String, hex: String)] = [
    ("蓝色", "#4A90D9"),
    ("红色", "#E74C3C"),
    ("绿色", "#2ECC71"),
    ("橙色", "#F39C12"),
    ("紫色", "#9B59B6"),
    ("青色", "#1ABC9C"),
    ("粉色", "#E91E63"),
    ("灰色", "#95A5A6"),
]
