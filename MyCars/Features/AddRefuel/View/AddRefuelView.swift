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
                LabeledTextField(title: "Пробіг", text: $viewModel.mileage, keyboardType: .numberPad)
                LabeledTextField(title: "Кількість палива", text: $viewModel.amount, keyboardType: .decimalPad)
                LabeledTextField(title: "Ціна за одиницю", text: $viewModel.pricePerUnit, keyboardType: .decimalPad)

                Toggle("Повна заправка", isOn: $viewModel.isFullCharge)
                    .padding(.vertical, 4)

                DatePicker("Дата заправки", selection: $viewModel.date, displayedComponents: .date)

                CustomButton(title: "Зберегти") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
            .textFieldStyle(.roundedBorder)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Нова заправка".uppercased())
    }
}
