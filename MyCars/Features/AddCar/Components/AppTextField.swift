import SwiftUI

enum MeasurementUnit: String {
    case kilometers = "км"
    case liters = "л"
    case hryvnias = "грн"
    case hryvniasPerLiter = "грн/л"
    case kilometersPerLiter = "км/л"
    case litersPer100Kilometers = "л/100 км"
}

enum AppTextFieldState: Equatable {
    case idle
    case focused
    case invalid(String)
    case disabled
}

struct AppTextField: View {
    typealias Validator = (String) -> String?

    var placeholder: String = ""
    var accessibilityLabel: String?
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var unit: MeasurementUnit?
    var isDisabled = false
    var validator: Validator?
    var onStateChange: (AppTextFieldState) -> Void = { _ in }

    @FocusState private var isFocused: Bool
    @State private var errorMessage: String?

    private var state: AppTextFieldState {
        if isDisabled { return .disabled }
        if let errorMessage { return .invalid(errorMessage) }
        return isFocused ? .focused : .idle
    }

    private var borderColor: Color {
        switch state {
        case .focused:
            Color("field_focused")
        case .invalid:
            Color("field_error")
        case .idle, .disabled:
            Color("field_border")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .accessibilityLabel(accessibilityLabel ?? placeholder)
                    .focused($isFocused)
                    .font(.system(size: 15))
                    .keyboardType(keyboardType)
                    .disabled(isDisabled)
                    .onSubmit {
                        validate()
                        notifyStateChange()
                    }

                if let unit {
                    Divider()
                        .frame(height: 18)

                    Text(unit.rawValue)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("field_background"))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isFocused || errorMessage != nil ? 2 : 1)
            }
            .opacity(isDisabled ? 0.5 : 1)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("field_error"))
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: errorMessage)
        .onChange(of: isFocused) { _, focused in
            if !focused {
                validate()
            }
            notifyStateChange()
        }
        .onChange(of: text) {
            if isFocused, errorMessage != nil {
                errorMessage = nil
                notifyStateChange()
            }
        }
        .onChange(of: isDisabled) {
            notifyStateChange()
        }
        .onAppear {
            notifyStateChange()
        }
    }

    private func validate() {
        errorMessage = validator?(text)
    }

    private func notifyStateChange() {
        onStateChange(state)
    }
}

enum TextFieldValidator {
    static func required(field: String) -> AppTextField.Validator {
        message { try FormValidation.required($0, field: field) }
    }

    static func integer(field: String, minimum: Int = 0) -> AppTextField.Validator {
        message { try FormValidation.integer($0, field: field, minimum: minimum) }
    }

    static func decimal(field: String, minimum: Double = 0) -> AppTextField.Validator {
        message { try FormValidation.decimal($0, field: field, minimum: minimum) }
    }

    static func optionalInteger(field: String, minimum: Int = 0) -> AppTextField.Validator {
        optional { try FormValidation.integer($0, field: field, minimum: minimum) }
    }

    static func optionalDecimal(field: String, minimum: Double = 0) -> AppTextField.Validator {
        optional { try FormValidation.decimal($0, field: field, minimum: minimum) }
    }

    private static func message<T>(for validation: @escaping (String) throws -> T) -> AppTextField.Validator {
        { value in
            do {
                _ = try validation(value)
                return nil
            } catch {
                return error.localizedDescription
            }
        }
    }

    private static func optional<T>(validation: @escaping (String) throws -> T) -> AppTextField.Validator {
        { value in
            guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return nil
            }
            return message(for: validation)(value)
        }
    }
}
