//
//  InsuranceTickerView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 18.06.2026.
//

import SwiftUI

struct InsuranceTickerView: View {
    let validUntil: Date

    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat? = nil
    @State private var hasStarted = false

    private var text: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "СТРАХОВКА ДІЙСНА ДО \(formatter.string(from: validUntil))"
    }

    var body: some View {
        GeometryReader { containerGeo in
            HStack(spacing: 8) {
                tickerText
                tickerText
                tickerText
            }
            .offset(x: offset)
            .frame(width: containerGeo.size.width, alignment: .leading)
            .clipped()
        }
        .frame(height: 18)
        .background(Color("ticker_background"))
        .onChange(of: textWidth) { _, newValue in
            guard let w = newValue, !hasStarted else { return }
            hasStarted = true
            startAnimation(width: w)
        }
    }

    private var tickerText: some View {
        Text(text)
            .font(.system(size: 10, weight: .black))
            .textCase(.uppercase)
            .foregroundColor(.white)
            .padding(.vertical, 2)
            .fixedSize()
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            textWidth = geo.size.width
                        }
                }
            )
    }

    private func startAnimation(width: CGFloat) {
        offset = 0
        let duration = Double(width / 30)

        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = -width
        }
    }
}
