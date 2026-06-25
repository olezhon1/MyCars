//
//  CarServiceCard.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.06.2026.
//

import SwiftUI

struct CarServiceCard: View {
    let type: CarServiceType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 20) {

                if let imageName = type.image {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

                Text(type.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(Color("primary"))
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("primary"), lineWidth: 1)
            )
        }
    }
}
