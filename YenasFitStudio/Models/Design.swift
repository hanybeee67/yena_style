//
//  Design.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import Foundation

struct Design: Identifiable, Codable {
    let id: UUID
    var name: String
    var layers: [Layer]
    var bodyTemplate: String
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
