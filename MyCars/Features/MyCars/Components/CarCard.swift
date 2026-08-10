import SwiftUI

struct CarCard: View {
    let car: CarPresentation
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 2) {
                Text(car.title).font(.system(size: 24, weight: .black))
                Text(car.purchasePrice).font(.system(size: 20, weight: .black))
            }

            HStack(spacing: 16) {
                carImage
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                    StatView(title: "Пробіг при купівлі", value: car.purchaseMileage, style: .vertical)
                    StatView(title: "Середній розхід", value: car.averageConsumption, style: .vertical)
                    StatView(title: "Пробіг зараз", value: car.currentMileage, style: .vertical)
                    StatView(title: "Вкладено", value: car.totalExpenses, style: .vertical)
                }
            }

            if let insuranceEndDate = car.insuranceEndDate {
                InsuranceTickerView(validUntil: insuranceEndDate).clipShape(.rect(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color("ticker_background") : Color("primary"), lineWidth: isSelected ? 4 : 2)
        }
    }

    @ViewBuilder
    private var carImage: some View {
        if let data = car.imageData, let image = UIImage(data: data) {
            Image(uiImage: image).resizable().scaledToFill().frame(width: 125, height: 100).clipped().clipShape(.rect(cornerRadius: 12))
        } else {
            Image("car_banner").resizable().scaledToFit().frame(width: 125)
        }
    }
}
