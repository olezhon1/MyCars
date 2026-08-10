//
//  MyCarsView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import SwiftUI

struct MyCarsView: View {

    @Bindable var viewModel: MyCarsViewModel

    var body: some View {
        content(vm: viewModel)
            .onAppear { viewModel.load() }
            .alert("Помилка", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })) {
                Button("OK") { viewModel.dismissError() }
            } message: { Text(viewModel.errorMessage ?? "Невідома помилка") }
    }

    @ViewBuilder
    private func content(vm: MyCarsViewModel) -> some View {

        ScrollView {
            HStack(alignment: .center, spacing: 20) {
                StatView(title: "Всього витрачено", value: "19 032 грн", style: .horizontal)
                StatView(title: "В километрах", value: "19 грн / км", style: .horizontal)
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                ForEach(vm.cars) { car in
                    CarCard(car: car, isSelected: vm.selectedCarID == car.id)
                        .onTapGesture {
                            vm.onCarSelected(car.id)
                        }
                }
            }
            .padding(.horizontal, 20)

            CustomButton(title: "Додати нове авто", image: Image("car")) {
                vm.onAddCarTapped()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Мої авто".uppercased())
    }
}
