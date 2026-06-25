//
//  CarCard.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import SwiftUI

struct CarCard: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            title(car: car)
            carInfo(car: car)
            InsuranceTickerView(validUntil: car.insurances.first?.endDate ?? Date())
                .cornerRadius(8)
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("ticker_background"), lineWidth: 6)
        )
        
    }
    
    @ViewBuilder
    private func title(car: Car) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(car.brand) \(car.model) - \(car.year)")
                .font(.system(size: 24, weight: .black))
            Text("\(car.purchasePrice, specifier: "%.2f")$")
                .font(.system(size: 24, weight: .black))
        }
    }
    
    @ViewBuilder
    private func carInfo(car: Car) -> some View {
        HStack(spacing: 16) {
            if let data = car.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 125)
                    .cornerRadius(12)

            } else {
                Image("car_banner")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .frame(maxWidth: 125)

            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 24
            ) {
                StatView(title: "Куплена с пробегом", value: "205 422 км", style: .vertical)
                StatView(title: "Расход средний", value: "6.7 л", style: .vertical)
                StatView(title: "Пробег сейчас", value: "245 км", style: .vertical)
                StatView(title: "Вложено", value: "34 000 грн", style: .vertical)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)

            Text(value)
                .font(.headline.bold())
        }
        .foregroundColor(Color("primary"))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
