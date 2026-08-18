//
//  StatsView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct StatsView: View {
    
    @Bindable var viewModel: StatsViewModel

    var body: some View {
        content()
            .onAppear { viewModel.load() }
    }
    
    @ViewBuilder
    private func content() -> some View {

        ScrollView {
            periodPicker(vm: viewModel)

            HStack(alignment: .center, spacing: 20) {
                StatView(title: "Всього витрачено", value: viewModel.stats.totalExpenses, style: .horizontal)
                StatView(title: "На кілометр", value: viewModel.stats.costPerKilometer, style: .horizontal)
            }
            .padding(.bottom, 24)
            .padding(.horizontal, 20)
            
            carsServiceSection(vm: viewModel)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Cтатитсика".uppercased())
    }
    
    @ViewBuilder
    private func carsServiceSection(vm: StatsViewModel) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(CarServiceType.allCases) { type in
                CarServiceStatCard(type: type, value: vm.stats.valuesByService[type] ?? "0 грн") {
                    viewModel.didSelect(type)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func periodPicker(vm: StatsViewModel) -> some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    vm.selectedPeriod = period
                } label: {
                    Text(period.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("primary"))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background {
                            if vm.selectedPeriod == period {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("primary"), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 20)
    }
}
