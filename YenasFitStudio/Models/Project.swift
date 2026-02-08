//
//  Project.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

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
