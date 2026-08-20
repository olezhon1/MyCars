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
                    valueColumn(title: "common.cost", value: formattedAmount)
                    valueColumn(title: "car.field.mileage", value: formattedMileage)
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
            Text(L10n.text(title))
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
        L10n.currency(item.amount)
    }

    private var formattedMileage: String {
        guard let mileage = item.mileage else { return "—" }
        return "\(L10n.integer(mileage)) \(L10n.text("unit.kilometers"))"
    }

    private var formattedDate: String {
        item.date.formatted(
            .dateTime
                .day(.twoDigits)
                .month(.twoDigits)
                .year(.twoDigits)
                .locale(L10n.locale)
        )
    }
}
