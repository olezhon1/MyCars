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
                LabeledTextField(title: "Марка", text: $viewModel.brand)
                LabeledTextField(title: "Модель", text: $viewModel.model)
                LabeledTextField(title: "Рік", text: $viewModel.year, keyboardType: .numberPad)
                LabeledTextField(title: "Ціна купівлі", text: $viewModel.purchasePrice, keyboardType: .decimalPad)
                LabeledTextField(title: "Пробіг при купівлі", text: $viewModel.purchaseMileage, keyboardType: .numberPad)
                LabeledTextField(title: "Об'єм / ємність", text: $viewModel.energyCapacity, keyboardType: .decimalPad)
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
            .textFieldStyle(.roundedBorder)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Нове авто".uppercased())
    }
    
}
