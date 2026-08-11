//
//  LabeledTextField.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct LabeledTextField: View {
    let title: String
    var placeholder: String = ""

    @Binding var text: String

    var keyboardType: UIKeyboardType = .default
    var unit: MeasurementUnit?
    var isDisabled = false
    var validator: AppTextField.Validator?

    @State private var fieldState: AppTextFieldState = .idle

    private var titleColor: Color {
        switch fieldState {
        case .focused:
            Color("field_focused")
        case .invalid:
            .red
        case .idle, .disabled:
            .secondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(titleColor)
                .animation(.easeOut(duration: 0.2), value: fieldState)

            AppTextField(
                placeholder: placeholder,
                text: $text,
                keyboardType: keyboardType,
                unit: unit,
                isDisabled: isDisabled,
                validator: validator,
                onStateChange: { fieldState = $0 }
            )
        }
    }
}
