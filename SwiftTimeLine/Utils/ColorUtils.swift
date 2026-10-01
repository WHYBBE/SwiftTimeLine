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

let presetColors: [String] = [
    "#4A90D9",
    "#E74C3C",
    "#2ECC71",
    "#F39C12",
    "#9B59B6",
    "#1ABC9C",
    "#E91E63",
    "#95A5A6",
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
    @Environment(\.loc) private var loc
    @Binding var selectedColor: String
    var dotSize: CGFloat = 20

    @State private var customColor: Color = .blue

    var body: some View {
        HStack(spacing: 6) {
            ForEach(presetColors, id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle().strokeBorder(.white, lineWidth: selectedColor == hex ? 2 : 0)
                    )
                    .shadow(color: selectedColor == hex ? Color(hex: hex) : .clear, radius: 3)
                    .onTapGesture { selectedColor = hex }
            }

            Button(action: { selectedColor = randomColorHex() }) {
                Image(systemName: "dice")
                    .font(.system(size: dotSize * 0.6))
                    .frame(width: dotSize, height: dotSize)
            }
            .buttonStyle(.borderless)
            .help(loc(.randomColor))

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
