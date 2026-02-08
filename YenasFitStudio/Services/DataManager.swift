//
//  DataManager.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  업데이트: 파일 기반 저장 및 자동 저장 기능 추가
//

import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var projects: [Project] = []
    @Published var currentProject: Project? {
        didSet {
            if let project = currentProject {
                autoSaveProject(project)
            }
        }
    }
    @Published var inspirationImages: [Data] = []
    
    private let projectsKey = "saved_projects"
    private let inspirationKey = "inspiration_images"
    
    private var autoSaveTimer: Timer?
    
    private var documentsURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    init() {
        loadProjects()
        loadInspirationImages()
        setupAutoSave()
    }
    
    deinit {
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Auto Save
    
    private func setupAutoSave() {
        // 30초마다 자동 저장
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.saveAllProjects()
        }
    }
    
    private func autoSaveProject(_ project: Project) {
        // 프로젝트가 변경될 때마다 저장
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.saveProjectToFile(project)
        }
    }
    
    // MARK: - Project Management
    
    func createProject(_ project: Project) {
        projects.append(project)
        currentProject = project
        saveProjects()
        saveProjectToFile(project)
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        if currentProject?.id == project.id {
            currentProject = nil
        }
        deleteProjectFile(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
            saveProjectToFile(project)
        }
    }
    
    // MARK: - File-based Persistence
    
    private func saveProjectToFile(_ project: Project) {
        guard let documentsURL = documentsURL else { return }
        
        let projectsFolder = documentsURL.appendingPathComponent("Projects")
        
        // 폴더 생성
        try? FileManager.default.createDirectory(at: projectsFolder, withIntermediateDirectories: true)
        
        let fileURL = projectsFolder.appendingPathComponent("\(project.id.uuidString).yfs")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(project) {
            try? data.write(to: fileURL)
        }
    }
    
    private func loadProjectFromFile(id: UUID) -> Project? {
        guard let documentsURL = documentsURL else { return nil }
        
        let fileURL = documentsURL
            .appendingPathComponent("Projects")
            .appendingPathComponent("\(id.uuidString).yfs")
        
        guard let data = try? Data(contentsOf: fileURL),
              let project = try? JSONDecoder().decode(Project.self, from: data) else {
            return nil
        }
        
        return project
    }
    
    private func deleteProjectFile(_ project: Project) {
        guard let documentsURL = documentsURL else { return }
        
        let fileURL = documentsURL
            .appendingPathComponent("Projects")
            .appendingPathComponent("\(project.id.uuidString).yfs")
        
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func saveAllProjects() {
        saveProjects()
        for project in projects {
            saveProjectToFile(project)
        }
    }
    
    // MARK: - UserDefaults Persistence (for metadata)
    
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
    
    // MARK: - Project Loading
    
    func loadFullProject(id: UUID) -> Project? {
        return loadProjectFromFile(id: id)
    }
}
