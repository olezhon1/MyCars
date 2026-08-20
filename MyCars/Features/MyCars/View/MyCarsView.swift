//
//  MyCarsView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 19.06.2026.
//

import SwiftUI

struct MyCarsView: View {

    @Bindable var viewModel: MyCarsViewModel
    @State private var deletionRequest: CarDeletionRequest?

    var body: some View {
        content(vm: viewModel)
            .onAppear { viewModel.load() }
            .alert("Помилка", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })) {
                Button("OK") { viewModel.dismissError() }
            } message: { Text(viewModel.errorMessage ?? "Невідома помилка") }
#if DEBUG
            .alert("Тестові дані", isPresented: Binding(get: { viewModel.debugMessage != nil }, set: { if !$0 { viewModel.dismissDebugMessage() } })) {
                Button("Готово") { viewModel.dismissDebugMessage() }
            } message: { Text(viewModel.debugMessage ?? "") }
#endif
            .alert(
                "Видалити автомобіль?",
                isPresented: deletionAlertPresented,
                presenting: deletionRequest
            ) { request in
                Button("Видалити", role: .destructive) {
                    var transaction = Transaction()
                    transaction.animation = nil
                    withTransaction(transaction) {
                        viewModel.deleteCar(request.id)
                    }
                }
                Button("Скасувати", role: .cancel) {}
            } message: { request in
                Text("Автомобіль «\(request.title)» та всю пов’язану історію буде видалено безповоротно.")
            }
    }

    private var deletionAlertPresented: Binding<Bool> {
        Binding(
            get: { deletionRequest != nil },
            set: { if !$0 { deletionRequest = nil } }
        )
    }

    private func requestDeletion(for car: CarPresentation) {
        var transaction = Transaction()
        transaction.animation = nil
        withTransaction(transaction) {
            deletionRequest = CarDeletionRequest(id: car.id, title: car.title)
        }
    }

    @ViewBuilder
    private func content(vm: MyCarsViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                HStack(alignment: .center, spacing: 20) {
                    StatView(title: "Всього витрачено", value: vm.stats.totalExpenses, style: .horizontal)
                    StatView(title: "На кілометр", value: vm.stats.costPerKilometer, style: .horizontal)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

                ForEach(vm.cars) { car in
                    CarCard(
                        car: car,
                        isSelected: vm.selectedCarID == car.id,
                        onSelect: { vm.onCarSelected(car.id) },
                        onEdit: { vm.onEditCarTapped(car.id) },
                        onDelete: { requestDeletion(for: car) }
                    )
                    .padding(.horizontal, 20)
                }

                CustomButton(title: "Додати нове авто", image: Image("car")) {
                    vm.onAddCarTapped()
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)

#if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("DEBUG")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Button {
                        vm.createDebugCars()
                    } label: {
                        Label("Створити тестові автомобілі", systemImage: "wrench.and.screwdriver.fill")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .accessibilityIdentifier("create-debug-cars")
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
#endif
            }
            .padding(.vertical, 8)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Мої авто".uppercased())
    }
}

private struct CarDeletionRequest {
    let id: UUID
    let title: String
}
