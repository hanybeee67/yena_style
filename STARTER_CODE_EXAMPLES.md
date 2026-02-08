# Yena's Fit Studio - 시작 코드 예시

이 문서는 앱 개발을 시작하기 위한 핵심 코드 예시를 제공합니다.

## 1. App Entry Point

### YenasFitStudioApp.swift

```swift
import SwiftUI

@main
struct YenasFitStudioApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
```

### ContentView.swift

```swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)
            
            if let currentProject = dataManager.currentProject {
                DesignWorkspaceView(project: currentProject)
                    .tabItem {
                        Label("작업", systemImage: "paintbrush.fill")
                    }
                    .tag(1)
            }
        }
    }
}
```

---

## 2. Data Models

### Project.swift

```swift
import Foundation

struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdDate: Date
    var designs: [Design]
    var category: Category
    var thumbnailData: Data?
    
    enum Category: String, Codable, CaseIterable {
        case menswear = "남성복"
        case womenswear = "여성복"
        case unisex = "유니섹스"
    }
    
    init(name: String, category: Category) {
        self.id = UUID()
        self.name = name
        self.createdDate = Date()
        self.designs = []
        self.category = category
    }
}
```

### Design.swift

```swift
import Foundation
import UIKit

struct Design: Identifiable, Codable {
    let id: UUID
    var name: String
    var layers: [Layer]
    var bodyTemplate: String // 템플릿 파일명
    var fabric: Fabric?
    var colorPalette: [String] // HEX 색상 코드
    var aiPrompt: String?
    
    init(name: String, bodyTemplate: String) {
        self.id = UUID()
        self.name = name
        self.layers = [Layer(name: "배경", content: .empty)]
        self.bodyTemplate = bodyTemplate
        self.colorPalette = []
    }
}
```

### Layer.swift

```swift
import Foundation
import PencilKit

struct Layer: Identifiable, Codable {
    let id: UUID
    var name: String
    var isVisible: Bool
    var opacity: Double
    var blendMode: String
    var content: LayerContent
    
    enum LayerContent: Codable {
        case empty
        case drawing(Data)      // PKDrawing.dataRepresentation()
        case image(Data)        // UIImage PNG data
        case texture(String)    // 텍스처 파일명
        
        // Codable 구현
        enum CodingKeys: String, CodingKey {
            case type, data, filename
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .empty:
                try container.encode("empty", forKey: .type)
            case .drawing(let data):
                try container.encode("drawing", forKey: .type)
                try container.encode(data, forKey: .data)
            case .image(let data):
                try container.encode("image", forKey: .type)
                try container.encode(data, forKey: .data)
            case .texture(let filename):
                try container.encode("texture", forKey: .type)
                try container.encode(filename, forKey: .filename)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "empty":
                self = .empty
            case "drawing":
                let data = try container.decode(Data.self, forKey: .data)
                self = .drawing(data)
            case "image":
                let data = try container.decode(Data.self, forKey: .data)
                self = .image(data)
            case "texture":
                let filename = try container.decode(String.self, forKey: .filename)
                self = .texture(filename)
            default:
                self = .empty
            }
        }
    }
    
    init(name: String, content: LayerContent) {
        self.id = UUID()
        self.name = name
        self.isVisible = true
        self.opacity = 1.0
        self.blendMode = "normal"
        self.content = content
    }
}
```

### Fabric.swift

```swift
import Foundation

struct Fabric: Codable {
    var type: FabricType
    var textureName: String // Assets에 있는 이미지 파일명
    var scale: Double // 텍스처 크기 배율
    
    enum FabricType: String, Codable, CaseIterable {
        case cotton = "면 (Cotton)"
        case silk = "실크 (Silk)"
        case denim = "데님 (Denim)"
        case leather = "가죽 (Leather)"
        case wool = "울 (Wool)"
        case velvet = "벨벳 (Velvet)"
        case linen = "린넨 (Linen)"
        case polyester = "폴리에스터"
        
        var defaultTexture: String {
            switch self {
            case .cotton: return "fabric_cotton"
            case .silk: return "fabric_silk"
            case .denim: return "fabric_denim"
            case .leather: return "fabric_leather"
            case .wool: return "fabric_wool"
            case .velvet: return "fabric_velvet"
            case .linen: return "fabric_linen"
            case .polyester: return "fabric_polyester"
            }
        }
    }
    
    init(type: FabricType) {
        self.type = type
        self.textureName = type.defaultTexture
        self.scale = 1.0
    }
}
```

---

## 3. Core Views

### DashboardView.swift

```swift
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingNewProjectSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 새 프로젝트 버튼
                    Button(action: {
                        showingNewProjectSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                            Text("새 프로젝트 시작")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // 프로젝트 갤러리
                    Text("내 포트폴리오")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ProjectGalleryView(projects: dataManager.projects)
                    
                    // 영감 보드
                    Text("영감 보드")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    InspirationBoardView()
                }
                .padding(.top)
            }
            .navigationTitle("Yena's Fit Studio")
            .sheet(isPresented: $showingNewProjectSheet) {
                NewProjectSheet()
            }
        }
    }
}

struct NewProjectSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var projectName = ""
    @State private var selectedCategory: Project.Category = .womenswear
    
    var body: some View {
        NavigationView {
            Form {
                Section("프로젝트 정보") {
                    TextField("프로젝트 이름", text: $projectName)
                    
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(Project.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("바디 템플릿") {
                    // TODO: 템플릿 선택 UI
                    Text("템플릿 선택 (추후 구현)")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("새 프로젝트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("생성") {
                        createProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
    
    private func createProject() {
        let project = Project(name: projectName, category: selectedCategory)
        dataManager.createProject(project)
        dismiss()
    }
}
```

### DesignWorkspaceView.swift

```swift
import SwiftUI

struct DesignWorkspaceView: View {
    @ObservedObject var project: Project
    @State private var currentDesign: Design?
    @State private var showingLayerPanel = false
    @State private var selectedTool: DrawingTool = .pen
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                HStack(spacing: 0) {
                    // 좌측 툴바
                    DrawingToolbar(selectedTool: $selectedTool, showLayerPanel: $showingLayerPanel)
                        .frame(width: 80)
                    
                    // 중앙 캔버스
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
                        
                        // 캔버스
                        if let design = currentDesign {
                            CanvasView(design: design, selectedTool: $selectedTool)
                        } else {
                            Text("디자인을 선택하세요")
                                .foregroundColor(.secondary)
                        }
                        
                        // 하단 AI 프롬프트
                        AIPromptBar(onGenerate: { prompt in
                            generateDesign(prompt: prompt)
                        })
                    }
                    
                    // 우측 속성 패널
                    PropertiesPanel()
                        .frame(width: 250)
                }
            }
        }
        .onAppear {
            if currentDesign == nil, let firstDesign = project.designs.first {
                currentDesign = firstDesign
            } else if currentDesign == nil {
                // 새 디자인 생성
                let newDesign = Design(name: "Design 1", bodyTemplate: "female_front")
                project.designs.append(newDesign)
                currentDesign = newDesign
            }
        }
    }
    
    private func exportDesign() {
        // TODO: 내보내기 구현
    }
    
    private func generateDesign(prompt: String) {
        // TODO: AI 생성 구현
    }
}

enum DrawingTool {
    case pen, pencil, marker, eraser
}
```

---

## 4. PencilKit Integration

### PencilKitCanvasView.swift

```swift
import SwiftUI
import PencilKit

struct PencilKitCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.tool = tool
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        
        // 드로잉 변경 감지
        canvas.delegate = context.coordinator
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
        uiView.tool = tool
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        
        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// 사용 예시:
struct CanvasView: View {
    @ObservedObject var design: Design
    @Binding var selectedTool: DrawingTool
    @State private var pkDrawing = PKDrawing()
    
    var pkTool: PKTool {
        switch selectedTool {
        case .pen:
            return PKInkingTool(.pen, color: .black, width: 2)
        case .pencil:
            return PKInkingTool(.pencil, color: .black, width: 1)
        case .marker:
            return PKInkingTool(.marker, color: .yellow, width: 10)
        case .eraser:
            return PKEraserTool(.bitmap)
        }
    }
    
    var body: some View {
        ZStack {
            // 바디 템플릿 (배경)
            Image(design.bodyTemplate)
                .resizable()
                .scaledToFit()
                .opacity(0.3)
            
            // 레이어 렌더링
            ForEach(design.layers.filter { $0.isVisible }) { layer in
                LayerView(layer: layer)
            }
            
            // PencilKit 드로잉
            PencilKitCanvasView(drawing: $pkDrawing, tool: .constant(pkTool))
        }
    }
}
```

---

## 5. Data Manager

### DataManager.swift

```swift
import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var projects: [Project] = []
    @Published var currentProject: Project?
    @Published var inspirationImages: [Data] = []
    
    private let projectsKey = "saved_projects"
    private let inspirationKey = "inspiration_images"
    
    init() {
        loadProjects()
        loadInspirationImages()
    }
    
    // MARK: - Project Management
    
    func createProject(_ project: Project) {
        projects.append(project)
        currentProject = project
        saveProjects()
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        if currentProject?.id == project.id {
            currentProject = nil
        }
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    // MARK: - Persistence
    
    private func saveProjects() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(projects) {
            UserDefaults.standard.set(data, forKey: projectsKey)
        }
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    private func loadInspirationImages() {
        if let data = UserDefaults.standard.data(forKey: inspirationKey),
           let decoded = try? JSONDecoder().decode([Data].self, from: data) {
            inspirationImages = decoded
        }
    }
    
    func addInspirationImage(_ imageData: Data) {
        inspirationImages.append(imageData)
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(inspirationImages) {
            UserDefaults.standard.set(data, forKey: inspirationKey)
        }
    }
    
    // MARK: - Export
    
    func exportAsPNG(design: Design) -> Data? {
        // TODO: 레이어를 합쳐서 PNG로 렌더링
        return nil
    }
    
    func exportAsPDF(design: Design) -> Data? {
        // TODO: 작업지시서 PDF 생성
        return nil
    }
}
```

---

## 6. UI Components

### DrawingToolbar.swift

```swift
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

extension DrawingTool {
    var name: String {
        switch self {
        case .pen: return "펜"
        case .pencil: return "연필"
        case .marker: return "마커"
        case .eraser: return "지우개"
        }
    }
}
```

### AIPromptBar.swift

```swift
import SwiftUI

struct AIPromptBar: View {
    @State private var prompt = ""
    let onGenerate: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("예: 빨간색 벨벳 오프숄더 드레스, A라인 스커트", text: $prompt)
                .textFieldStyle(.roundedBorder)
                .padding(.leading)
            
            Button(action: {
                if !prompt.isEmpty {
                    onGenerate(prompt)
                }
            }) {
                Text("생성")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(prompt.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(prompt.isEmpty)
            .padding(.trailing)
        }
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
}
```

### PropertiesPanel.swift

```swift
import SwiftUI

struct PropertiesPanel: View {
    @State private var selectedFabric: Fabric.FabricType = .cotton
    @State private var selectedColor: Color = .white
    @State private var fabricScale: Double = 1.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("속성")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                // 원단 선택
                VStack(alignment: .leading) {
                    Text("원단")
                        .font(.headline)
                    
                    Picker("원단 선택", selection: $selectedFabric) {
                        ForEach(Fabric.FabricType.allCases, id: \.self) { fabric in
                            Text(fabric.rawValue).tag(fabric)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // 텍스처 프리뷰
                    Image(selectedFabric.defaultTexture)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(8)
                    
                    Text("크기")
                        .font(.subheadline)
                    Slider(value: $fabricScale, in: 0.5...2.0)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 색상 선택
                VStack(alignment: .leading) {
                    Text("색상")
                        .font(.headline)
                    
                    ColorPicker("색상 선택", selection: $selectedColor)
                }
                .padding(.horizontal)
                
                Divider()
                
                // 패턴 오버레이
                VStack(alignment: .leading) {
                    Text("패턴")
                        .font(.headline)
                    
                    HStack {
                        PatternButton(name: "체크", imageName: "pattern_check")
                        PatternButton(name: "스트라이프", imageName: "pattern_stripe")
                        PatternButton(name: "플라워", imageName: "pattern_flower")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .background(.ultraThinMaterial)
    }
}

struct PatternButton: View {
    let name: String
    let imageName: String
    @State private var isSelected = false
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}
```

---

## 7. 다음 단계

이 코드를 사용하여:

1. **Xcode 프로젝트 생성**
2. 각 파일을 해당하는 경로에 생성
3. **Preview 실행**하여 UI 확인

```swift
#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(DataManager())
            .previewDevice("iPad Pro (12.9-inch)")
    }
}
#endif
```

개발 시작 준비 완료! 🎨
