//
//  InspirationBoardView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import SwiftUI
import PhotosUI

struct InspirationBoardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedItems: [PhotosPickerItem] = []
    
    let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            if dataManager.inspirationImages.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("영감을 주는 이미지를 추가하세요")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    PhotosPicker(selection: $selectedItems,
                                 maxSelectionCount: 10,
                                 matching: .images) {
                        Text("이미지 추가")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .onChange(of: selectedItems) { newItems in
                        loadImages(from: newItems)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(dataManager.inspirationImages.enumerated()), id: \.offset) { index, imageData in
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    
                    // 추가 버튼
                    PhotosPicker(selection: $selectedItems,
                                 maxSelectionCount: 10,
                                 matching: .images) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                    .onChange(of: selectedItems) { newItems in
                        loadImages(from: newItems)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let imageData = data {
                        DispatchQueue.main.async {
                            dataManager.addInspirationImage(imageData)
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
        selectedItems = []
    }
}

#if DEBUG
struct InspirationBoardView_Previews: PreviewProvider {
    static var previews: some View {
        InspirationBoardView()
            .environmentObject(DataManager())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
