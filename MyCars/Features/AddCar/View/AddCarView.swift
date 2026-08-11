//
//  AddCarView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct AddCarView: View {
    
    @Bindable var viewModel: AddCarViewModel
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
                GeometryReader { geo in
                    let width = geo.size.width * 0.5
                    CarPhotoPickerButton(imageData: $viewModel.selectedImageData)
                        .frame(width: width, height: width * 0.75)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 160)
                LabeledTextField(
                    title: "Марка",
                    text: $viewModel.brand,
                    validator: TextFieldValidator.required(field: "Марка")
                )
                LabeledTextField(
                    title: "Модель",
                    text: $viewModel.model,
                    validator: TextFieldValidator.required(field: "Модель")
                )
                LabeledTextField(
                    title: "Рік",
                    text: $viewModel.year,
                    keyboardType: .numberPad,
                    validator: TextFieldValidator.integer(field: "Рік", minimum: 1886)
                )
                LabeledTextField(
                    title: "Ціна купівлі",
                    text: $viewModel.purchasePrice,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "Ціна купівлі")
                )
                LabeledTextField(
                    title: "Пробіг при купівлі",
                    text: $viewModel.purchaseMileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.integer(field: "Пробіг")
                )
                LabeledTextField(
                    title: "Об'єм / ємність",
                    text: $viewModel.energyCapacity,
                    keyboardType: .decimalPad,
                    unit: .liters,
                    validator: TextFieldValidator.decimal(field: "Об’єм / ємність")
                )
                Picker("Тип двигуна", selection: $viewModel.powertrain) {
                    ForEach(PowertrainType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                
                DatePicker("Дата купівлі", selection: $viewModel.purchaseDate, displayedComponents: .date)
                
                CustomButton(title: "Зберегти") {
                    viewModel.save()
                }
                    .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Нове авто".uppercased())
    }
    
}
