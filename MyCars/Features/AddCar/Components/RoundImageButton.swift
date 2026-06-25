//
//  RoundImageButton.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct RoundImageButton: View {
    let image: String

    var body: some View {
        Image(systemName: image)
            .resizable()
            .scaledToFit()
            .padding(8)
            .frame(width: 32, height: 32)
            .background(.white)
            .foregroundColor(Color("primary"))
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color("primary"), lineWidth: 0.5)
            )
    }
}
