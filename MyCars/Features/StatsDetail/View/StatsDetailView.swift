//
//  StatsDetailView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 11.08.2026.
//

import SwiftUI
import Charts

struct StatsDetailView: View {
    
    @Bindable var viewModel: StatsDetailViewModel
    @State private var displayMode: StatsDisplayMode = .chart

    var body: some View {
        content()
            .onAppear { viewModel.load() }
            .alert("statistics.error.load", isPresented: errorPresented) {
                Button("common.ok") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? L10n.text("common.unknownError"))
            }
            .toolbar {
                if viewModel.hasData {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            displayMode.toggle()
                        } label: {
                            Image(displayMode.toggleImageName)
                                .renderingMode(.template)
                                .foregroundStyle(Color("primary"))
                        }
                        .accessibilityLabel(displayMode.toggleAccessibilityLabel)
                    }
                }
            }
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )
    }
    
    @ViewBuilder
    private func content() -> some View {

        ScrollView {
            periodPicker(vm: viewModel, periods: [.halfYear, .year, .allTime])

            if viewModel.hasData {
                if displayMode == .chart {
                    amountChart(expenses: viewModel.expenses)
                }

                expenseHistory(sections: visibleExpenseSections)
            } else {
                StatisticsEmptyState(serviceTitle: viewModel.serviceTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                    .padding(.horizontal, 24)
            }
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("tab.statistics").uppercased())
    }
    
    @ViewBuilder
    private func periodPicker(vm: StatsDetailViewModel, periods: [StatsPeriod]) -> some View {
        HStack(spacing: 0) {
            ForEach(periods, id: \.self) { period in
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
    
    @ViewBuilder
    private func amountChart(expenses: [ExpensePoint]) -> some View {
        switch viewModel.selectedPeriod {
        case .month, .halfYear:
            barChart(expenses: expenses, widthRatio: 0.65)
        case .year:
            barChart(expenses: expenses, widthRatio: 0.5)
        case .allTime:
            allTimeChart(expenses: expenses)
        }
    }

    @ViewBuilder
    private func barChart(expenses: [ExpensePoint], widthRatio: Double) -> some View {
        let maximum = max(expenses.map(\.amount).max() ?? 0, 1)
        let verticalPadding = maximum * 0.08

        Chart(expenses) { expense in
            BarMark(
                x: .value(L10n.text("statistics.period.month"), monthKey(for: expense.month)),
                yStart: .value(L10n.text("chart.start"), 0),
                yEnd: .value(L10n.text("common.amount"), expense.amount),
                width: .ratio(widthRatio)
            )
            .cornerRadius(18)
            .foregroundStyle(
                isSelected(expense.month)
                    ? Color("bar_mark_selected")
                    : Color("bar_mark_default")
            )
            .offset(y: -2)
        }
        .chartXScale(
            range: .plotDimension(startPadding: 16, endPadding: 16)
        )
        .chartXAxis {
            AxisMarks(values: expenses.map { monthKey(for: $0.month) }) { value in
                if let key = value.as(String.self),
                   let expense = expenses.first(where: { monthKey(for: $0.month) == key }) {
                    AxisValueLabel(
                        centered: true,
                        collisionResolution: .greedy
                    ) {
                        Text(expense.month, format: .dateTime.month(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(
                                isSelected(expense.month)
                                    ? Color("bar_mark_selected")
                                    : Color.secondary
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.selectMonth(expense.month)
                            }
                    }
                }
            }
        }
        .chartOverlay { proxy in
            selectionOverlay(proxy: proxy, expenses: expenses)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYScale(
            domain: (-verticalPadding)...(maximum + verticalPadding)
        )
        .padding(.horizontal, 16)
        .frame(height: 240)
    }

    @ViewBuilder
    private func allTimeChart(expenses: [ExpensePoint]) -> some View {
        let maximum = max(expenses.map(\.amount).max() ?? 0, 1)
        let verticalPadding = maximum * 0.08
        let monthKeys = expenses.map { monthKey(for: $0.month) }
        let visibleMonthCount = min(max(expenses.count, 1), 12)
        let initialMonthKey = monthKeys.dropLast(11).last ?? monthKeys.first ?? ""

        VStack(spacing: 0) {
            Chart(expenses) { expense in
                BarMark(
                    x: .value(L10n.text("statistics.period.month"), monthKey(for: expense.month)),
                    yStart: .value(L10n.text("chart.start"), 0),
                    yEnd: .value(L10n.text("common.amount"), expense.amount),
                    width: .ratio(0.6)
                )
                .cornerRadius(18)
                .foregroundStyle(
                    isSelected(expense.month)
                        ? Color("bar_mark_selected")
                        : Color("bar_mark_default")
                )
                .offset(y: -2)
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleMonthCount)
            .chartScrollPosition(initialX: initialMonthKey)
            .chartXScale(
                range: .plotDimension(startPadding: 16, endPadding: 16)
            )
            .chartXAxis {
                AxisMarks(values: monthKeys) { value in
                    if let key = value.as(String.self),
                       let expense = expenses.first(where: { monthKey(for: $0.month) == key }) {
                        AxisValueLabel(centered: true) {
                            Text(expense.month, format: .dateTime.month(.abbreviated))
                                .font(.caption2)
                                .foregroundStyle(
                                    isSelected(expense.month)
                                        ? Color("bar_mark_selected")
                                        : Color.secondary
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectMonth(expense.month)
                                }
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                selectionOverlay(proxy: proxy, expenses: expenses)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(
                domain: (-verticalPadding)...(maximum + verticalPadding)
            )
            .frame(height: 240)
        }
        .padding(.horizontal, 16)
    }

    private func selectionOverlay(
        proxy: ChartProxy,
        expenses: [ExpensePoint]
    ) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .simultaneousGesture(
                    SpatialTapGesture().onEnded { value in
                        guard let plotFrame = proxy.plotFrame else { return }
                        let frame = geometry[plotFrame]
                        guard frame.contains(value.location) else { return }

                        let xPosition = value.location.x - frame.minX
                        guard let key: String = proxy.value(atX: xPosition),
                              let expense = expenses.first(where: {
                                  monthKey(for: $0.month) == key
                              }) else { return }

                        viewModel.selectMonth(expense.month)
                    }
                )
        }
    }

    private func isSelected(_ month: Date) -> Bool {
        guard let selectedMonth = viewModel.selectedMonth else { return false }
        return Calendar.current.isDate(month, equalTo: selectedMonth, toGranularity: .month)
    }

    @ViewBuilder
    private func expenseHistory(sections: [ExpenseMonthSection]) -> some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 0) {
                    Text(sectionTitle(for: section.month))
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)

                    ForEach(section.items) { item in
                        ExpenseHistoryRow(item: item)
                    }
                }
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    private func sectionTitle(for month: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = L10n.locale
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")

        let components = formatter.string(from: month).split(separator: " ")
        guard let year = components.last else { return formatter.string(from: month).capitalized }
        let monthName = components.dropLast().joined(separator: " ").capitalized
        return "\(monthName) — \(year)"
    }

    private func monthKey(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)"
    }

    private var visibleExpenseSections: [ExpenseMonthSection] {
        guard displayMode == .chart else { return viewModel.expenseSections }
        guard let selectedMonth = viewModel.selectedMonth else { return [] }

        return viewModel.expenseSections.filter {
            Calendar.current.isDate(
                $0.month,
                equalTo: selectedMonth,
                toGranularity: .month
            )
        }
    }
}

private enum StatsDisplayMode {
    case chart
    case list

    var toggleImageName: String {
        switch self {
        case .chart: return "ic_list_view"
        case .list: return "ic_chart_view"
        }
    }

    var toggleAccessibilityLabel: String {
        switch self {
        case .chart: return L10n.text("statistics.showList")
        case .list: return L10n.text("statistics.showChart")
        }
    }

    mutating func toggle() {
        self = self == .chart ? .list : .chart
    }
}
