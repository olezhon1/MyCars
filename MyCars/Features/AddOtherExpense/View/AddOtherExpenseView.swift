import SwiftUI

struct AddOtherExpenseView: View {
    @Bindable var viewModel: AddOtherExpenseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LabeledTextField(title: "Назва витрати", text: $viewModel.title)
                LabeledTextField(title: "Вартість", text: $viewModel.price, keyboardType: .decimalPad)
                LabeledTextField(title: "Пробіг (необов’язково)", text: $viewModel.mileage, keyboardType: .numberPad)
                DatePicker("Дата витрати", selection: $viewModel.date, displayedComponents: .date)
                LabeledTextView(title: "Нотатки", placeholder: "Додаткова інформація...", text: $viewModel.notes)
                CustomButton(title: "Зберегти") { viewModel.save() }
                    .padding(.horizontal, 40)
            }
            .padding()
            .textFieldStyle(.roundedBorder)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Інша витрата".uppercased())
        .alert("Не вдалося зберегти", isPresented: errorPresented) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "Невідома помилка")
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })
    }
}
