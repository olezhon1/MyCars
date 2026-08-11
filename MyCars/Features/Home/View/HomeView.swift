//
//  HomeView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 06.06.2026.
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var scrollPosition: UUID?

    var body: some View {
        content()
            .onAppear {
                viewModel.load()
                scrollPosition = viewModel.selectedCarID
            }
            .onChange(of: scrollPosition) { _, id in
                if let id { viewModel.selectCar(id) }
            }
    }

    @ViewBuilder
    private func content() -> some View {

        ScrollView {
            VStack(spacing: 16) {

                carListSection(vm: viewModel)
                carsServiceSection(vm: viewModel)
            }
            .padding(.horizontal, 16)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Головна")
    }

    // MARK: - Sections

    @ViewBuilder
    private func carListSection(vm: HomeViewModel) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(vm.cars) { car in
                    CarOverviewCard(car: car)
                        .containerRelativeFrame(.horizontal)
                        .id(car.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrollPosition)

        HStack(spacing: 6) {
            ForEach(vm.cars) { car in
                Circle()
                    .fill(scrollPosition == car.id ? Color("primary") : Color("primary").opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    @ViewBuilder
    private func carsServiceSection(vm: HomeViewModel) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(CarServiceType.allCases) { type in
                CarServiceCard(type: type) {
                    viewModel.didSelect(type)
                }
            }
        }
    }
}
