//
//  AddMaintenanceView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 21.07.2026.
//

import SwiftUI

struct AddMaintenanceView: View {
    @Bindable var viewModel: AddMaintenanceViewModel
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
                    title: "common.title",
                    text: $viewModel.title,
                    validator: TextFieldValidator.required(field: "common.title")
                )

                LabeledTextField(
                    title: "common.cost",
                    text: $viewModel.price,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "common.cost", minimum: 0.01)
                )

                LabeledTextField(
                    title: "car.field.mileage",
                    text: $viewModel.mileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.integer(field: "car.field.mileage")
                )

                DatePicker("maintenance.field.date", selection: $viewModel.date, displayedComponents: .date)

                LabeledTextView(title: "common.notes", placeholder: "common.additionalInfo.placeholder", text: $viewModel.notes)

                CustomButton(title: "common.save") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("maintenance.add.title").uppercased())
    }
}
