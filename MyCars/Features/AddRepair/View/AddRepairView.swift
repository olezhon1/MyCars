import SwiftUI

struct AddRepairView: View {
    @Bindable var viewModel: AddRepairViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LabeledTextField(title: "Назва ремонту", text: $viewModel.title)
                LabeledTextField(title: "Вартість", text: $viewModel.price, keyboardType: .decimalPad)
                LabeledTextField(title: "Пробіг", text: $viewModel.mileage, keyboardType: .numberPad)
                DatePicker("Дата ремонту", selection: $viewModel.date, displayedComponents: .date)
                LabeledTextView(title: "Нотатки", placeholder: "Додаткова інформація...", text: $viewModel.notes)
                CustomButton(title: "Зберегти") { viewModel.save() }
                    .padding(.horizontal, 40)
            }
            .padding()
            .textFieldStyle(.roundedBorder)
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Новий ремонт".uppercased())
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
