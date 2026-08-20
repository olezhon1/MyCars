//
//  LabeledTextView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 21.07.2026.
//

import SwiftUI

struct LabeledTextView: View {
    let title: String
    var placeholder: String = ""
    @Binding var text: String
    var minHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.text(title))
                .font(Font.system(size: 14, weight: .regular))
                .foregroundColor(Color("primary"))

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(L10n.text(placeholder))
                        .font(.system(size: 16))
                        .foregroundColor(Color(.placeholderText))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .frame(minHeight: minHeight)
                    .padding(.horizontal, 4)
                    .scrollContentBackground(.hidden)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            }
        }
    }
}
