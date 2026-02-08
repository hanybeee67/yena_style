//
//  DesignWorkspaceView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  업데이트: PencilKit 드로잉 및 레이어 시스템 통합
//  업데이트: 내보내기 및 공유 기능 추가
//

import SwiftUI
import PencilKit

struct DesignWorkspaceView: View {
    let project: Project
    @State private var currentDesign: Design?
    @State private var selectedTool: DrawingTool = .pen
    @State private var showingLayerPanel = false
    @State private var selectedLayerId: UUID?
    @State private var showingExportMenu = false
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    
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
            .sheet(isPresented: $showingShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems) {
                        showingShareSheet = false
                        shareItems = []
                    }
                }
            }
            .confirmationDialog("내보내기", isPresented: $showingExportMenu) {
                Button("PNG로 내보내기") {
                    exportAs(.png)
                }
                
                Button("JPEG로 내보내기") {
                    exportAs(.jpeg)
                }
                
                Button("공유하기") {
                    shareDesign()
                }
                
                Button("취소", role: .cancel) {
                    showingExportMenu = false
                }
            } message: {
                Text("디자인을 어떻게 내보내시겠어요?")
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
        guard let design = currentDesign else { return }
        showingExportMenu = true
    }
    
    private func exportAs(_ format: ExportFormat) {
        guard let design = currentDesign else { return }
        
        let exportService = ExportService.shared
        let filename = "\(design.name)_\(Date().timeIntervalSince1970).\(format.fileExtension)"
        
        var imageData: Data?
        switch format {
        case .png:
            imageData = exportService.exportAsPNG(design: design)
        case .jpeg:
            imageData = exportService.exportAsJPEG(design: design)
        }
        
        guard let data = imageData,
              let fileURL = exportService.saveImageToDocuments(imageData: data, filename: filename) else {
            print("이미지 저장 실패")
            return
        }
        
        print("이미지 저장 성공: \(fileURL.path)")
        
        // 공유 시트 표시
        if let image = UIImage(data: data) {
            shareItems = [image, fileURL]
            showingShareSheet = true
        }
    }
    
    private func shareDesign() {
        guard let design = currentDesign else { return }
        
        let exportService = ExportService.shared
        shareItems = exportService.createShareItems(for: design, format: .png)
        showingShareSheet = true
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
