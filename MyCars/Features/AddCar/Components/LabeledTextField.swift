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

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(Font.system(size: 14, weight: .regular))
                .foregroundColor(Color("primary"))
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(keyboardType)
        }
    }
}
