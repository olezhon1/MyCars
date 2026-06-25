//
//  CustomButton.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct CustomButton: View {

    let title: String
    let image: Image?
    let action: () -> Void

    init(
        title: String,
        image: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {

                if let image {
                    image
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(Color("primary"))
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("primary"), lineWidth: 1)
            }
        }
    }
}
