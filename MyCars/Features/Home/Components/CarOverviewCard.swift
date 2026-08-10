import SwiftUI

struct CarOverviewCard: View {
    let car: CarPresentation

    var body: some View {
        VStack(spacing: 16) {
            Text(car.title).font(.title2).foregroundColor(Color("primary"))
            Text(car.currentMileage).font(.headline).foregroundColor(Color("primary"))

            if let insuranceEndDate = car.insuranceEndDate {
                InsuranceTickerView(validUntil: insuranceEndDate)
            }

            if let data = car.imageData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFit().frame(height: 130)
            } else {
                Image("car_banner").resizable().scaledToFit().frame(height: 130)
            }

            HStack(spacing: 12) {
                StatView(title: "Пробіг при купівлі", value: car.purchaseMileage, style: .vertical, alignment: .center)
                StatView(title: "Витрати", value: car.totalExpenses, style: .vertical, alignment: .center)
                StatView(title: "Розхід", value: car.averageConsumption, style: .vertical, alignment: .center)
            }
        }
    }
}
