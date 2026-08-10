import Foundation

enum FormValidation {
    static func required(_ value: String, field: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ValidationError.message("Заповніть поле «\(field)».") }
        return trimmed
    }

    static func integer(_ value: String, field: String, minimum: Int = 0) throws -> Int {
        guard let number = Int(value), number >= minimum else {
            throw ValidationError.message("Поле «\(field)» повинно містити число не менше \(minimum).")
        }
        return number
    }

    static func decimal(_ value: String, field: String, minimum: Double = 0) throws -> Double {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let number = Double(normalized), number >= minimum else {
            throw ValidationError.message("Поле «\(field)» повинно містити число не менше \(minimum).")
        }
        return number
    }
}

enum ValidationError: LocalizedError {
    case message(String)

    var errorDescription: String? {
        guard case .message(let message) = self else { return nil }
        return message
    }
}
