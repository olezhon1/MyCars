//
//  AddTuningModificationView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 10.08.2026.
//

import SwiftUI

struct AddTuningModificationView: View {
    @Bindable var viewModel: AddTuningModificationViewModel
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

                LabeledTextField(title: "Назва", text: $viewModel.name)

                LabeledTextField(title: "Вартість", text: $viewModel.price, keyboardType: .decimalPad)

                LabeledTextField(title: "Пробіг", text: $viewModel.mileage, keyboardType: .numberPad)

                DatePicker("Дата обслуговування", selection: $viewModel.date, displayedComponents: .date)

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
        .navigationTitle("Нове обслуговування".uppercased())
    }
}
