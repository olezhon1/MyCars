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
                GeometryReader { geo in
                    let width = geo.size.width * 0.5
                    CarPhotoPickerButton(imageData: $viewModel.selectedImageData)
                        .frame(width: width, height: width * 0.75)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 160)
                LabeledTextField(
                    title: "car.field.brand",
                    text: $viewModel.brand,
                    validator: TextFieldValidator.required(field: "car.field.brand")
                )
                LabeledTextField(
                    title: "car.field.model",
                    text: $viewModel.model,
                    validator: TextFieldValidator.required(field: "car.field.model")
                )
                LabeledTextField(
                    title: "common.year",
                    text: $viewModel.year,
                    keyboardType: .numberPad,
                    validator: TextFieldValidator.integer(field: "common.year", minimum: 1886)
                )
                LabeledTextField(
                    title: "car.field.purchasePrice",
                    text: $viewModel.purchasePrice,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "car.field.purchasePrice")
                )
                LabeledTextField(
                    title: "car.purchaseMileage",
                    text: $viewModel.purchaseMileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.integer(field: "car.field.mileage")
                )
                LabeledTextField(
                    title: "car.field.energyCapacity",
                    text: $viewModel.energyCapacity,
                    keyboardType: .decimalPad,
                    unit: .liters,
                    validator: TextFieldValidator.decimal(field: "car.field.energyCapacity")
                )
                
                DatePicker("car.field.purchaseDate", selection: $viewModel.purchaseDate, displayedComponents: .date)
                
                CustomButton(title: viewModel.saveButtonTitle) {
                    viewModel.save()
                }
                    .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.navigationTitle.uppercased())
    }
    
}
