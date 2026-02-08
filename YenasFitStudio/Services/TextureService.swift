//
//  TextureService.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  로컬 텍스처 오버레이 기능 (AI 없이 원단 질감 적용)
//

import Foundation
import UIKit
import PencilKit

class TextureService {
    static let shared = TextureService()
    
    private init() {}
    
    // MARK: - Texture Generation
    
    /// 단색으로 텍스처 패턴 생성 (실제 원단 이미지 대신 사용)
    func generateFabricTexture(type: Fabric.FabricType, color: UIColor, size: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // 기본 색상 배경
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 원단별 패턴 추가
            applyFabricPattern(type: type, context: context, size: size)
        }
        
        return image
    }
    
    private func applyFabricPattern(type: Fabric.FabricType, context: UIGraphicsImageRendererContext, size: CGSize) {
        let cgContext = context.cgContext
        
        switch type {
        case .cotton:
            // 면 - 작은 점들
            UIColor.white.withAlphaComponent(0.1).setFill()
            for _ in 0..<100 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 2, height: 2)
                cgContext.fillEllipse(in: rect)
            }
            
        case .denim:
            // 데님 - 대각선 패턴
            UIColor.white.withAlphaComponent(0.2).setStroke()
            cgContext.setLineWidth(1)
            for i in stride(from: -size.height, to: size.width + size.height, by: 4) {
                cgContext.move(to: CGPoint(x: i, y: 0))
                cgContext.addLine(to: CGPoint(x: i + size.height, y: size.height))
            }
            cgContext.strokePath()
            
        case .velvet:
            // 벨벳 - 부드러운 그라데이션
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: [UIColor.black.withAlphaComponent(0.2).cgColor,
                                             UIColor.white.withAlphaComponent(0.1).cgColor] as CFArray,
                                     locations: [0.0, 1.0])
            if let gradient = gradient {
                cgContext.drawRadialGradient(gradient,
                                            startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                            startRadius: 0,
                                            endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                            endRadius: size.width / 2,
                                            options: [])
            }
            
        case .silk:
            // 실크 - 반짝이는 효과
            UIColor.white.withAlphaComponent(0.3).setFill()
            for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 3, height: 1)
                cgContext.fill(rect)
            }
            
        case .leather:
            // 가죽 - 불규칙한 패턴
            UIColor.black.withAlphaComponent(0.1).setFill()
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let width = CGFloat.random(in: 5...15)
                let height = CGFloat.random(in: 5...15)
                let rect = CGRect(x: x, y: y, width: width, height: height)
                cgContext.fillEllipse(in: rect)
            }
            
        default:
            // 기타 원단 - 기본 패턴
            break
        }
    }
    
    // MARK: - Texture Application
    
    /// 드로잉 위에 텍스처 적용
    func applyTextureToDrawing(drawing: PKDrawing, texture: UIImage, blendMode: CGBlendMode = .multiply) -> UIImage? {
        let drawingImage = drawing.image(from: drawing.bounds, scale: 2.0)
        
        return applyTextureToImage(image: drawingImage, texture: texture, blendMode: blendMode)
    }
    
    /// 이미지 위에 텍스처 적용
    func applyTextureToImage(image: UIImage, texture: UIImage, blendMode: CGBlendMode = .multiply) -> UIImage? {
        let size = image.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let resultImage = renderer.image { context in
            // 원본 이미지 그리기
            image.draw(in: CGRect(origin: .zero, size: size))
            
            // 블렌드 모드 설정
            context.cgContext.setBlendMode(blendMode)
            
            // 텍스처 타일링하여 그리기
            texture.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return resultImage
    }
    
    /// 레이어에 텍스처 적용 (Layer 데이터 업데이트)
    func applyTextureToLayer(_ layer: Layer, fabric: Fabric, color: UIColor) -> Layer {
        var updatedLayer = layer
        
        // 텍스처 이미지 생성
        guard let textureImage = generateFabricTexture(type: fabric.type, color: color) else {
            return layer
        }
        
        // 레이어 내용에 따라 텍스처 적용
        switch layer.content {
        case .drawing(let data):
            if let drawing = try? PKDrawing(data: data),
               let resultImage = applyTextureToDrawing(drawing: drawing, texture: textureImage),
               let imageData = resultImage.pngData() {
                updatedLayer.content = .image(imageData)
            }
            
        case .image(let data):
            if let image = UIImage(data: data),
               let resultImage = applyTextureToImage(image: image, texture: textureImage),
               let imageData = resultImage.pngData() {
                updatedLayer.content = .image(imageData)
            }
            
        default:
            break
        }
        
        return updatedLayer
    }
}
