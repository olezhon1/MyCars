//
//  AddInsuranceView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.07.2026.
//

import SwiftUI

struct AddInsuranceView: View {
    @Bindable var viewModel: AddInsuranceViewModel
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
                    title: "insurance.field.policyNumber",
                    text: $viewModel.policyNumber,
                    validator: TextFieldValidator.required(field: "insurance.field.policyNumber")
                )
                LabeledTextField(
                    title: "insurance.field.company",
                    text: $viewModel.companyName,
                    validator: TextFieldValidator.required(field: "insurance.field.company")
                )
                
                LabeledTextField(
                    title: "common.cost",
                    text: $viewModel.price,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "common.cost", minimum: 0.01)
                )

                DatePicker("insurance.field.startDate", selection: $viewModel.startDate, displayedComponents: .date)
                DatePicker("insurance.field.endDate", selection: $viewModel.endDate, displayedComponents: .date)
                
                Picker("insurance.field.type", selection: $viewModel.type) {
                    ForEach(InsuranceType.allCases, id: \.self) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                CustomButton(title: "common.save") {
                    viewModel.save()
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("insurance.add.title").uppercased())
    }
}
