//
//  Fabric.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import Foundation

struct Fabric: Codable {
    var type: FabricType
    var textureName: String
    var scale: Double
    
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
