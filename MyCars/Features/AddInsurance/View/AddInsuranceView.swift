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
                
                LabeledTextField(title: "Номер полісу", text: $viewModel.policyNumber)
                LabeledTextField(title: "Страхова компанія", text: $viewModel.companyName)
                
                LabeledTextField(title: "Вартість", text: $viewModel.price, keyboardType: .decimalPad)

                DatePicker("Дата початку", selection: $viewModel.startDate, displayedComponents: .date)
                DatePicker("Дата закінчення", selection: $viewModel.endDate, displayedComponents: .date)
                
                Picker("Тип страховки", selection: $viewModel.type) {
                    ForEach(InsuranceType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
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
        .navigationTitle("Нова страховка".uppercased())
    }
}
