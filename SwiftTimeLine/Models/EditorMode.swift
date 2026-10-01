import Foundation

enum EditorMode<Value> {
    case add
    case edit(Value)

    var isEditing: Bool {
        if case .edit = self { return true }
        return false
    }

    var editingValue: Value? {
        if case .edit(let value) = self { return value }
        return nil
    }
}
