//
//  HomeView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 06.06.2026.
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var selectedIndex = 0
    @State private var scrollPosition: Int? = 0

    var body: some View {
        content()
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
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    CarOverviewCard()
                        .containerRelativeFrame(.horizontal)
                        .tag(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $scrollPosition)

        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(scrollPosition == index ? Color("primary") : Color("primary").opacity(0.3))
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

#Preview {
    HomeView(viewModel: HomeViewModel(router: AppRouter()))
}
