import SwiftUI

extension Color {
    static let defaultHex = "#4A90D9"

    init(hex: String) {
        self.init(nsColor: NSColor(hex: hex) ?? NSColor(hex: Color.defaultHex)!)
    }
}

extension NSColor {
    convenience init?(hex: String) {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        string = string.replacingOccurrences(of: "#", with: "").uppercased()
        guard !string.isEmpty else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: string).scanHexInt64(&value) else { return nil }

        let r, g, b, a: UInt64
        switch string.count {
        case 3:
            r = (value >> 8 & 0xF) * 17
            g = (value >> 4 & 0xF) * 17
            b = (value & 0xF) * 17
            a = 255
        case 6:
            r = value >> 16 & 0xFF
            g = value >> 8 & 0xFF
            b = value & 0xFF
            a = 255
        case 8:
            r = value >> 24 & 0xFF
            g = value >> 16 & 0xFF
            b = value >> 8 & 0xFF
            a = value & 0xFF
        default:
            return nil
        }

        self.init(
            srgbRed: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
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

func randomColorHex() -> String {
    let r = Int.random(in: 30...220)
    let g = Int.random(in: 30...220)
    let b = Int.random(in: 30...220)
    return String(format: "#%02X%02X%02X", r, g, b)
}

extension NSColor {
    var hexString: String {
        guard let rgb = usingColorSpace(.sRGB) else { return Color.defaultHex }
        let r = Int(rgb.redComponent * 255)
        let g = Int(rgb.greenComponent * 255)
        let b = Int(rgb.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

struct ColorPickerField: View {
    @Binding var selectedColor: String
    var dotSize: CGFloat = 20

    @State private var customColor: Color = .blue

    var body: some View {
        HStack(spacing: 6) {
            ForEach(presetColors, id: \.hex) { preset in
                Circle()
                    .fill(Color(hex: preset.hex))
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: selectedColor == preset.hex ? 2 : 0)
                    )
                    .shadow(color: selectedColor == preset.hex ? Color(hex: preset.hex) : .clear, radius: 3)
                    .onTapGesture { selectedColor = preset.hex }
            }

            Button(action: { selectedColor = randomColorHex() }) {
                Image(systemName: "dice")
                    .font(.system(size: dotSize * 0.6))
                    .frame(width: dotSize, height: dotSize)
            }
            .buttonStyle(.borderless)
            .help("随机颜色")

            ColorPicker("", selection: $customColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: dotSize + 4, height: dotSize)
                .onChange(of: customColor) { _, newValue in
                    selectedColor = NSColor(newValue).hexString
                }
        }
        .onAppear {
            customColor = Color(hex: selectedColor)
        }
        .onChange(of: selectedColor) { _, newValue in
            customColor = Color(hex: newValue)
        }
    }
}
