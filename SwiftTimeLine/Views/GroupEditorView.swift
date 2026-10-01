import SwiftUI

struct GroupEditorView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.loc) private var loc
    @Environment(\.dismiss) private var dismiss

    let mode: EditorMode<TimelineGroup>

    @State private var name: String = ""
    @State private var color: String = "#4A90D9"
    @State private var symbol: String?
    @State private var emoji: String = ""

    private var isEditing: Bool { mode.isEditing }

    var body: some View {
        VStack(spacing: 0) {
            Text(isEditing ? loc(.editGroup) : loc(.newGroup))
                .font(.headline)
                .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    field(title: loc(.name)) {
                        TextField(loc(.groupNamePlaceholder), text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    field(title: loc(.color)) {
                        ColorPickerField(selectedColor: $color, dotSize: 18)
                    }

                    iconSection
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button(loc(.cancel)) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isEditing ? loc(.save) : loc(.create)) { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .frame(width: 420, height: 480)
        .onAppear(perform: loadFromMode)
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(loc(.icon))
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Button(loc(.resetToDefault)) {
                    symbol = nil
                    emoji = ""
                }
                .font(.caption)
                .buttonStyle(.borderless)
                .disabled(symbol == nil && emoji.isEmpty)
            }

            HStack(spacing: 10) {
                GroupIconView(
                    emoji: emoji.isEmpty ? nil : emoji,
                    symbol: symbol,
                    color: Color(hex: color),
                    size: 24
                )
                .padding(6)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                TextField(loc(.emoji), text: $emoji)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 120)
                    .onChange(of: emoji) { _, newValue in
                        emoji = String(newValue.prefix(1))
                    }

                Spacer()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 34), spacing: 8)], spacing: 8) {
                ForEach(GroupIconPresets.symbols, id: \.self) { preset in
                    symbolButton(preset)
                }
            }
        }
    }

    private func symbolButton(_ preset: String) -> some View {
        let isSelected = symbol == preset && emoji.isEmpty
        return Button {
            emoji = ""
            symbol = isSelected ? nil : preset
        } label: {
            Image(systemName: preset)
                .font(.system(size: 15))
                .frame(width: 30, height: 30)
                .background(isSelected ? Color(hex: color).opacity(0.25) : Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .strokeBorder(isSelected ? Color(hex: color) : .clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func loadFromMode() {
        if let group = mode.editingValue {
            name = group.name
            color = group.color
            symbol = group.symbol
            emoji = group.emoji ?? ""
        } else {
            color = randomColorHex()
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let normalizedEmoji = emoji.isEmpty ? nil : emoji

        if var group = mode.editingValue {
            group.name = trimmed
            group.color = color
            group.symbol = symbol
            group.emoji = normalizedEmoji
            store.updateGroup(group)
        } else {
            store.addGroup(name: trimmed, color: color, symbol: symbol, emoji: normalizedEmoji)
        }
        dismiss()
    }
}
