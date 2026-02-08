//
//  DesignWorkspaceView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  MVP Version - 기본 레이아웃만 구현
//

import SwiftUI

struct DesignWorkspaceView: View {
    let project: Project
    @State private var selectedTool: DrawingTool = .pen
    @State private var showingLayerPanel = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 타이틀 바
                    HStack {
                        Text(project.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: { showingLayerPanel.toggle() }) {
                            Label("레이어", systemImage: "square.stack.3d.up")
                        }
                        
                        Button(action: {}) {
                            Label("내보내기", systemImage: "square.and.arrow.up")
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    
                    // 메인 영역
                    HStack(spacing: 0) {
                        // 좌측 툴바
                        DrawingToolbar(selectedTool: $selectedTool, showLayerPanel: $showingLayerPanel)
                            .frame(width: 80)
                        
                        // 중앙 캔버스
                        VStack {
                            Text("캔버스 영역")
                                .foregroundColor(.secondary)
                            Text("PencilKit 통합 예정")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        
                        // 우측 속성 패널
                        PropertiesPanel()
                            .frame(width: 250)
                    }
                }
            }
        }
    }
}

enum DrawingTool {
    case pen, pencil, marker, eraser
    
    var name: String {
        switch self {
        case .pen: return "펜"
        case .pencil: return "연필"
        case .marker: return "마커"
        case .eraser: return "지우개"
        }
    }
}

#if DEBUG
struct DesignWorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "테스트 프로젝트", category: .womenswear)
        DesignWorkspaceView(project: project)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
