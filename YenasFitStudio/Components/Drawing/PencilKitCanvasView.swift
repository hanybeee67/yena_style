//
//  PencilKitCanvasView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  PencilKit을 SwiftUI에서 사용하기 위한 UIViewRepresentable 래퍼
//

import SwiftUI
import PencilKit

struct PencilKitCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    var onDrawingChanged: ((PKDrawing) -> Void)?
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.tool = tool
        
        // 손가락과 애플펜슬 모두 사용 가능
        canvas.drawingPolicy = .anyInput
        
        // 투명 배경 설정 (레이어 시스템을 위해)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
        // 드로잉 변경 감지를 위한 delegate 설정
        canvas.delegate = context.coordinator
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
        uiView.tool = tool
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, onDrawingChanged: onDrawingChanged)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var onDrawingChanged: ((PKDrawing) -> Void)?
        
        init(drawing: Binding<PKDrawing>, onDrawingChanged: ((PKDrawing) -> Void)?) {
            _drawing = drawing
            self.onDrawingChanged = onDrawingChanged
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
            onDrawingChanged?(canvasView.drawing)
        }
    }
}
