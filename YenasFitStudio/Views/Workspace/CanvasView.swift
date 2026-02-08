//
//  CanvasView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  메인 캔버스 - 레이어 시스템과 PencilKit 통합
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @Binding var design: Design
    @Binding var selectedTool: DrawingTool
    @Binding var selectedLayerId: UUID?
    
    @State private var currentDrawing = PKDrawing()
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var currentTool: PKTool {
        switch selectedTool {
        case .pen:
            return PKInkingTool(.pen, color: .black, width: 2)
        case .pencil:
            return PKInkingTool(.pencil, color: .black, width: 1)
        case .marker:
            return PKInkingTool(.marker, color: .yellow.withAlphaComponent(0.5), width: 10)
        case .eraser:
            return PKEraserTool(.bitmap)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 그리드
                GridPattern()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                
                // 레이어 렌더링
                ZStack {
                    // 바디 템플릿 (배경)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 600)
                        .opacity(0.1)
                        .foregroundColor(.gray)
                    
                    // 모든 레이어 렌더링
                    ForEach(design.layers.filter { $0.isVisible }) { layer in
                        LayerContentView(layer: layer)
                            .opacity(layer.opacity)
                    }
                    
                    // 현재 선택된 레이어의 드로잉 영역
                    if let selectedId = selectedLayerId,
                       let layerIndex = design.layers.firstIndex(where: { $0.id == selectedId }) {
                        PencilKitCanvasView(
                            drawing: binding(for: layerIndex),
                            tool: .constant(currentTool),
                            onDrawingChanged: { newDrawing in
                                updateLayerDrawing(at: layerIndex, with: newDrawing)
                            }
                        )
                    }
                }
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
    
    private func binding(for index: Int) -> Binding<PKDrawing> {
        Binding(
            get: {
                if case .drawing(let data) = design.layers[index].content,
                   let drawing = try? PKDrawing(data: data) {
                    return drawing
                }
                return PKDrawing()
            },
            set: { newDrawing in
                design.layers[index].content = .drawing(newDrawing.dataRepresentation())
            }
        )
    }
    
    private func updateLayerDrawing(at index: Int, with drawing: PKDrawing) {
        design.layers[index].content = .drawing(drawing.dataRepresentation())
    }
}

// 그리드 패턴 배경
struct GridPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let gridSize: CGFloat = 20
        
        // 세로선
        for x in stride(from: 0, to: rect.width, by: gridSize) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // 가로선
        for y in stride(from: 0, to: rect.height, by: gridSize) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// 레이어 내용 렌더링
struct LayerContentView: View {
    let layer: Layer
    
    var body: some View {
        switch layer.content {
        case .empty:
            EmptyView()
            
        case .drawing(let data):
            if let drawing = try? PKDrawing(data: data) {
                DrawingView(drawing: drawing)
            }
            
        case .image(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
        case .texture(let filename):
            Image(filename)
                .resizable()
                .scaledToFit()
        }
    }
}

// PKDrawing을 SwiftUI View로 렌더링
struct DrawingView: View {
    let drawing: PKDrawing
    
    var body: some View {
        GeometryReader { geometry in
            if let image = drawing.image(from: drawing.bounds, scale: 1.0) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

#if DEBUG
struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(
            design: .constant(Design(name: "테스트", bodyTemplate: "female_front")),
            selectedTool: .constant(.pen),
            selectedLayerId: .constant(nil)
        )
        .frame(width: 800, height: 1000)
    }
}
#endif
