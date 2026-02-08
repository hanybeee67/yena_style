//
//  Layer.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

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
