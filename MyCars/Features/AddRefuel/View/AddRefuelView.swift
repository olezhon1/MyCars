//
//  AddRefuelView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 02.07.2026.
//

import SwiftUI

struct AddRefuelView: View {
    @Bindable var viewModel: AddRefuelViewModel
    var body: some View {
        content()
            .alert("Не вдалося зберегти", isPresented: errorPresented) {
                Button("OK") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "Невідома помилка")
            }
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })
    }

    @ViewBuilder
    private func content() -> some View {

        ScrollView {
            VStack(spacing: 16) {
                LabeledTextField(
                    title: "Пробіг",
                    text: $viewModel.mileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.integer(field: "Пробіг")
                )
                LabeledTextField(
                    title: "Кількість палива",
                    text: $viewModel.amount,
                    keyboardType: .decimalPad,
                    unit: .liters,
                    validator: TextFieldValidator.decimal(field: "Кількість палива", minimum: 0.01)
                )
                LabeledTextField(
                    title: "Ціна за одиницю",
                    text: $viewModel.pricePerUnit,
                    keyboardType: .decimalPad,
                    unit: .hryvniasPerLiter,
                    validator: TextFieldValidator.decimal(field: "Ціна за одиницю", minimum: 0.01)
                )

                DatePicker("Дата заправки", selection: $viewModel.date, displayedComponents: .date)

                CustomButton(title: "Зберегти") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Нова заправка".uppercased())
    }
}
