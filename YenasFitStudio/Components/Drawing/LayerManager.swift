//
//  LayerManager.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  레이어 관리 UI - 포토샵 스타일 레이어 패널
//

import SwiftUI

struct LayerManager: View {
    @Binding var layers: [Layer]
    @Binding var selectedLayerId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("레이어")
                    .font(.headline)
                
                Spacer()
                
                Button(action: addLayer) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            List {
                ForEach($layers) { $layer in
                    LayerRow(
                        layer: $layer,
                        isSelected: selectedLayerId == layer.id,
                        onSelect: {
                            selectedLayerId = layer.id
                        }
                    )
                }
                .onMove { from, to in
                    layers.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { indexSet in
                    layers.remove(atOffsets: indexSet)
                }
            }
            .listStyle(.plain)
        }
        .frame(width: 300)
        .background(.ultraThinMaterial)
    }
    
    private func addLayer() {
        let newLayer = Layer(name: "레이어 \(layers.count + 1)", content: .empty)
        layers.append(newLayer)
        selectedLayerId = newLayer.id
    }
}

struct LayerRow: View {
    @Binding var layer: Layer
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            // 가시성 토글
            Button(action: {
                layer.isVisible.toggle()
            }) {
                Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(layer.isVisible ? .blue : .gray)
            }
            .buttonStyle(.borderless)
            
            // 레이어 썸네일 (추후 실제 내용 표시)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: contentIcon)
                        .foregroundColor(.gray)
                )
            
            // 레이어 이름
            TextField("레이어 이름", text: $layer.name)
                .textFieldStyle(.plain)
            
            // 투명도 표시
            Text("\(Int(layer.opacity * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(6)
        .onTapGesture {
            onSelect()
        }
    }
    
    private var contentIcon: String {
        switch layer.content {
        case .empty:
            return "square.dashed"
        case .drawing:
            return "pencil.tip"
        case .image:
            return "photo"
        case .texture:
            return "square.grid.2x2"
        }
    }
}

#if DEBUG
struct LayerManager_Previews: PreviewProvider {
    static var previews: some View {
        LayerManager(
            layers: .constant([
                Layer(name: "배경", content: .empty),
                Layer(name: "스케치", content: .empty),
                Layer(name: "색상", content: .empty)
            ]),
            selectedLayerId: .constant(nil)
        )
    }
}
#endif
