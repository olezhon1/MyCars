//
//  CarServiceStatCard.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 25.06.2026.
//

import SwiftUI

struct CarServiceStatCard: View {
    let type: CarServiceType
    let value: String

    var body: some View {
        VStack(spacing: 12) {
            if let imageName = type.image {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }

            Text(type.title)
                .font(.system(size: 12, weight: .regular))

            Text(value)
                .font(.system(size: 16, weight: .black))
        }
        .foregroundColor(Color("primary"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .background(type.color)
        .cornerRadius(12)
    }
}
