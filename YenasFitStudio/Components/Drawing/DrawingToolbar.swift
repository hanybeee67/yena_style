//
//  DrawingToolbar.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import SwiftUI

struct DrawingToolbar: View {
    @Binding var selectedTool: DrawingTool
    @Binding var showLayerPanel: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            ToolButton(icon: "pencil", tool: .pen, isSelected: selectedTool == .pen) {
                selectedTool = .pen
            }
            
            ToolButton(icon: "pencil.tip", tool: .pencil, isSelected: selectedTool == .pencil) {
                selectedTool = .pencil
            }
            
            ToolButton(icon: "highlighter", tool: .marker, isSelected: selectedTool == .marker) {
                selectedTool = .marker
            }
            
            ToolButton(icon: "eraser", tool: .eraser, isSelected: selectedTool == .eraser) {
                selectedTool = .eraser
            }
            
            Divider()
                .padding(.vertical)
            
            Button(action: { showLayerPanel.toggle() }) {
                VStack {
                    Image(systemName: "square.stack.3d.up")
                        .font(.title2)
                    Text("레이어")
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
}

struct ToolButton: View {
    let icon: String
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .primary)
                Text(tool.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
    }
}

#if DEBUG
struct DrawingToolbar_Previews: PreviewProvider {
    static var previews: some View {
        DrawingToolbar(selectedTool: .constant(.pen), showLayerPanel: .constant(false))
            .frame(width: 80, height: 600)
    }
}
#endif
