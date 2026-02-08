//
//  PropertiesPanel.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  업데이트: 텍스처 적용 기능 추가
//

import SwiftUI

struct PropertiesPanel: View {
    @State private var selectedFabric: Fabric.FabricType = .cotton
    @State private var selectedColor: Color = .blue
    @State private var fabricScale: Double = 1.0
    @State private var showingTexturePreview = false
    
    var onApplyTexture: ((Fabric.FabricType, Color) -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("속성")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                // 원단 선택
                VStack(alignment: .leading, spacing: 8) {
                    Text("원단")
                        .font(.headline)
                    
                    Picker("원단 선택", selection: $selectedFabric) {
                        ForEach(Fabric.FabricType.allCases, id: \.self) { fabric in
                            Text(fabric.rawValue).tag(fabric)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // 텍스처 프리뷰
                    Button(action: {
                        showingTexturePreview.toggle()
                    }) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedColor)
                            .frame(height: 80)
                            .overlay(
                                VStack {
                                    Image(systemName: "square.grid.2x2")
                                        .font(.title)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(selectedFabric.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            )
                    }
                    
                    Text("크기")
                        .font(.subheadline)
                    Slider(value: $fabricScale, in: 0.5...2.0)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 색상 선택
                VStack(alignment: .leading, spacing: 8) {
                    Text("색상")
                        .font(.headline)
                    
                    ColorPicker("색상 선택", selection: $selectedColor)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 텍스처 적용 버튼
                VStack(alignment: .leading, spacing: 8) {
                    Text("텍스처 적용")
                        .font(.headline)
                    
                    Button(action: {
                        onApplyTexture?(selectedFabric, UIColor(selectedColor))
                    }) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                            Text("선택한 레이어에 적용")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Text("현재 선택된 레이어에 원단 텍스처가 적용됩니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 패턴 오버레이 (추후 구현)
                VStack(alignment: .leading, spacing: 8) {
                    Text("패턴")
                        .font(.headline)
                    
                    Text("패턴 기능은 추후 추가됩니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .background(.ultraThinMaterial)
    }
}

#if DEBUG
struct PropertiesPanel_Previews: PreviewProvider {
    static var previews: some View {
        PropertiesPanel()
            .frame(width: 250, height: 600)
    }
}
#endif
