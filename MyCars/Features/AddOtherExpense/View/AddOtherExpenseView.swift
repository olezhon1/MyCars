import SwiftUI

struct AddOtherExpenseView: View {
    @Bindable var viewModel: AddOtherExpenseViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                LabeledTextField(
                    title: "otherExpense.field.title",
                    text: $viewModel.title,
                    validator: TextFieldValidator.required(field: "common.title")
                )
                LabeledTextField(
                    title: "common.cost",
                    text: $viewModel.price,
                    keyboardType: .decimalPad,
                    unit: .hryvnias,
                    validator: TextFieldValidator.decimal(field: "common.cost", minimum: 0.01)
                )
                LabeledTextField(
                    title: "car.field.mileageOptional",
                    text: $viewModel.mileage,
                    keyboardType: .numberPad,
                    unit: .kilometers,
                    validator: TextFieldValidator.optionalInteger(field: "car.field.mileage")
                )
                DatePicker("otherExpense.field.date", selection: $viewModel.date, displayedComponents: .date)
                LabeledTextView(title: "common.notes", placeholder: "common.additionalInfo.placeholder", text: $viewModel.notes)
                CustomButton(title: "common.save") { viewModel.save() }
                    .padding(.horizontal, 40)
            }
            .padding()
        }
        .background(Color("background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.text("otherExpense.add.title").uppercased())
        .alert("common.error.save", isPresented: errorPresented) {
            Button("common.ok") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? L10n.text("common.unknownError"))
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.dismissError() } })
    }
}
