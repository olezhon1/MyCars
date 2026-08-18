//
//  ExpenseHistoryRow.swift
//  MyCars
//

import SwiftUI

struct ExpenseHistoryRow: View {
    let item: ExpenseHistoryItem

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 24) {
                expenseImage
                    .frame(width: 24, height: 24)

                HStack(alignment: .bottom, spacing: 12) {
                    valueColumn(title: "Вартість", value: formattedAmount)
                    valueColumn(title: "Пробіг", value: formattedMileage)
                    valueColumn(title: item.dateTitle, value: formattedDate)
                }
            }

            Divider()
                .padding(.init(top: 0, leading: 48, bottom: 0, trailing: 36))
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    @ViewBuilder
    private var expenseImage: some View {
        if let imageName = item.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("primary"))
        } else {
            Image(systemName: "creditcard")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color("primary"))
        }
    }

    private func valueColumn(title: String, value: String) -> some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formattedAmount: String {
        let value = item.amount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(0...2))
                .locale(Locale(identifier: "uk_UA"))
        )
        return "\(value) грн"
    }

    private var formattedMileage: String {
        guard let mileage = item.mileage else { return "—" }
        return mileage.formatted(
            .number
                .grouping(.automatic)
                .locale(Locale(identifier: "uk_UA"))
        )
    }

    private var formattedDate: String {
        item.date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
                .locale(Locale(identifier: "uk_UA"))
        )
    }
}
