//
//  DesignWorkspaceView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  업데이트: PencilKit 드로잉 및 레이어 시스템 통합
//

import SwiftUI
import PencilKit

struct DesignWorkspaceView: View {
    let project: Project
    @State private var currentDesign: Design?
    @State private var selectedTool: DrawingTool = .pen
    @State private var showingLayerPanel = false
    @State private var selectedLayerId: UUID?
    
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
                        
                        Button(action: exportDesign) {
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
                        ZStack {
                            if let design = currentDesign {
                                CanvasView(
                                    design: Binding(
                                        get: { design },
                                        set: { currentDesign = $0 }
                                    ),
                                    selectedTool: $selectedTool,
                                    selectedLayerId: $selectedLayerId
                                )
                            } else {
                                VStack {
                                    Image(systemName: "paintbrush.pointed")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                    Text("디자인을 시작하세요")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // 우측 속성 패널
                        PropertiesPanel()
                            .frame(width: 250)
                    }
                }
                
                // 레이어 패널 (오버레이)
                if showingLayerPanel, let design = currentDesign {
                    HStack {
                        Spacer()
                        
                        LayerManager(
                            layers: Binding(
                                get: { design.layers },
                                set: { currentDesign?.layers = $0 }
                            ),
                            selectedLayerId: $selectedLayerId
                        )
                        .transition(.move(edge: .trailing))
                    }
                    .background(Color.black.opacity(0.3))
                    .onTapGesture {
                        showingLayerPanel = false
                    }
                }
            }
        }
        .onAppear {
            initializeDesign()
        }
    }
    
    private func initializeDesign() {
        if currentDesign == nil {
            var newDesign = Design(name: "Design 1", bodyTemplate: "female_front")
            // 기본 레이어 3개 생성
            newDesign.layers = [
                Layer(name: "배경", content: .empty),
                Layer(name: "스케치", content: .drawing(PKDrawing().dataRepresentation())),
                Layer(name: "색상", content: .empty)
            ]
            currentDesign = newDesign
            selectedLayerId = newDesign.layers[1].id // 스케치 레이어 선택
        }
    }
    
    private func exportDesign() {
        // TODO: 내보내기 구현
        print("내보내기 기능 추후 구현")
    }
}

#if DEBUG
struct DesignWorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        let project = Project(name: "테스트 프로젝트", category: .womenswear)
        DesignWorkspaceView(project: project)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif


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
