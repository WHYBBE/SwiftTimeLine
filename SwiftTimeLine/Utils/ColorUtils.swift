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

func randomColorHex() -> String {
    let r = Int.random(in: 30...220)
    let g = Int.random(in: 30...220)
    let b = Int.random(in: 30...220)
    return String(format: "#%02X%02X%02X", r, g, b)
}

extension NSColor {
    var hexString: String {
        guard let rgb = usingColorSpace(.sRGB) else { return "#4A90D9" }
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
