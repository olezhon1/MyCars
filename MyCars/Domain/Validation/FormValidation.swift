import Foundation

enum FormValidation {
    static func required(_ value: String, field: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.message(L10n.text("validation.required", L10n.text(field)))
        }
        return trimmed
    }

    static func integer(_ value: String, field: String, minimum: Int = 0) throws -> Int {
        guard let number = Int(value) else {
            throw ValidationError.message(L10n.text("validation.invalidInteger", L10n.text(field)))
        }
        guard number >= minimum else {
            throw ValidationError.message(L10n.text("validation.minimumInteger", L10n.text(field), minimum))
        }
        return number
    }

    static func decimal(_ value: String, field: String, minimum: Double = 0) throws -> Double {
        let normalized = value.replacingOccurrences(of: ",", with: ".")
        guard let number = Double(normalized) else {
            throw ValidationError.message(L10n.text("validation.invalidNumber", L10n.text(field)))
        }
        guard number >= minimum else {
            throw ValidationError.message(L10n.text("validation.minimumNumber", L10n.text(field), minimum.formatted()))
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
