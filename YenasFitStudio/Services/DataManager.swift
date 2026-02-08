//
//  DataManager.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

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
}
