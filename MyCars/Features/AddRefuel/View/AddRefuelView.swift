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
                    validator: TextFieldValidator.integer(field: "car.field.mileage")
                )
                LabeledTextField(
                    title: "refuel.field.amount",
                    text: $viewModel.amount,
                    keyboardType: .decimalPad,
                    unit: .liters,
                    validator: TextFieldValidator.decimal(field: "refuel.field.amount", minimum: 0.01)
                )
                LabeledTextField(
                    title: "refuel.field.unitPrice",
                    text: $viewModel.pricePerUnit,
                    keyboardType: .decimalPad,
                    unit: .hryvniasPerLiter,
                    validator: TextFieldValidator.decimal(field: "refuel.field.unitPrice", minimum: 0.01)
                )

                DatePicker("refuel.field.date", selection: $viewModel.date, displayedComponents: .date)

                CustomButton(title: "common.save") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("refuel.add.title").uppercased())
    }
}
