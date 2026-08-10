//
//  AddCarWashView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.07.2026.
//

import SwiftUI

struct AddCarWashView: View {
    @Bindable var viewModel: AddCarWashViewModel
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
                LabeledTextField(title: "Вартість мийки", text: $viewModel.price, keyboardType: .decimalPad)

                DatePicker("Дата мийки", selection: $viewModel.date, displayedComponents: .date)

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
        .navigationTitle("Автомийка".uppercased())
    }
}
