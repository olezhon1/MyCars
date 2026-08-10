//
//  CarPhotoPickerButton.swift
//  MyCars
//
//  Created by Oleksandr Semeniuk on 24.06.2026.
//

import SwiftUI
import PhotosUI

struct CarPhotoPickerButton: View {

    @State private var selectedItem: PhotosPickerItem?
    @Binding var imageData: Data?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                if let data = imageData,
                   let uiImage = UIImage(data: data) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .cornerRadius(12)
                    
                } else {
                    Image("car_banner")
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                }
                
                RoundImageButton(image: "camera")
                    .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .cornerRadius(16)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color("primary"),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [6, 4]
                        )
                    )
            }

        }
        .onChange(of: selectedItem) { _, newValue in
            guard let newValue else { return }

            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.imageData = data
                    }
                }
            }
        }
    }
}
