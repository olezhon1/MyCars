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
            .alert("common.error.save", isPresented: errorPresented) {
                Button("common.ok") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? L10n.text("common.unknownError"))
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
                    title: "car.field.mileage",
                    text: $viewModel.mileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.optionalInteger(field: "car.field.mileage")
                )
                LabeledTextField(
                    title: "carWash.field.cost",
                    text: $viewModel.price,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "common.cost", minimum: 0.01)
                )

                DatePicker("carWash.field.date", selection: $viewModel.date, displayedComponents: .date)

                CustomButton(title: "common.save") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("carWash.add.title").uppercased())
    }
}
