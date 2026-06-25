//
//  CarOverviewCard.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.06.2026.
//

import SwiftUI

struct CarOverviewCard: View {

    private var insuranceDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 12
        components.day = 21
        components.hour = 20
        components.minute = 25
        
        return Calendar.current.date(from: components)!
    }
    
    var body: some View {
        VStack(spacing: 16) {

            Text("Dacia Logan 1 - 2005")
                .font(.title2)
                .foregroundColor(Color("primary"))

            Text("245 422 км")
                .font(.headline)
                .foregroundColor(Color("primary"))

            InsuranceTickerView(validUntil: insuranceDate)

            Image("car_banner")

            HStack(spacing: 12) {
                StatView(title: "ТО через", value: "555 км", style: .vertical, alignment: .center)
                StatView(title: "Затрати", value: "34 000 грн", style: .vertical, alignment: .center)
                StatView(title: "Розхід", value: "6.7 л", style: .vertical, alignment: .center)
            }
        }
    }
}
