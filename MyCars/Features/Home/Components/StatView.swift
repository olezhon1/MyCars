//
//  StatView.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI

struct StatView: View {
    enum Style {
        case horizontal
        case vertical
    }

    let title: String
    let value: String
    var style: Style = .horizontal
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        switch style {
        case .horizontal:
            HStack(spacing: 10) {
                Text(L10n.text(title))
                    .font(.system(size: 10, weight: .semibold))
                Text(value)
                    .font(.system(size: 10, weight: .black))
            }
            .foregroundColor(Color("primary"))
        case .vertical:
            VStack(alignment: alignment, spacing: 6) {
                Text(L10n.text(title))
                    .font(.caption)
                Text(value)
                    .font(.headline.bold())
            }
            .foregroundColor(Color("primary"))
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .center))
        }
    }
}
