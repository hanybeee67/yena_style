//
//  ExportService.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  이미지 내보내기 및 공유 기능
//

import Foundation
import UIKit
import PencilKit

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    // MARK: - Image Export
    
    /// 디자인의 모든 레이어를 합쳐서 단일 이미지로 렌더링
    func renderDesignAsImage(design: Design, size: CGSize = CGSize(width: 2000, height: 3000)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // 흰색 배경
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 각 레이어 렌더링
            for layer in design.layers where layer.isVisible {
                context.cgContext.saveGState()
                context.cgContext.setAlpha(layer.opacity)
                
                switch layer.content {
                case .empty:
                    break
                    
                case .drawing(let data):
                    if let drawing = try? PKDrawing(data: data) {
                        let drawingImage = drawing.image(from: drawing.bounds, scale: 2.0)
                        drawingImage.draw(in: CGRect(origin: .zero, size: size))
                    }
                    
                case .image(let data):
                    if let uiImage = UIImage(data: data) {
                        uiImage.draw(in: CGRect(origin: .zero, size: size))
                    }
                    
                case .texture(let filename):
                    if let textureImage = UIImage(named: filename) {
                        textureImage.draw(in: CGRect(origin: .zero, size: size))
                    }
                }
                
                context.cgContext.restoreGState()
            }
        }
        
        return image
    }
    
    /// PNG 형식으로 내보내기
    func exportAsPNG(design: Design, quality: CGFloat = 1.0) -> Data? {
        guard let image = renderDesignAsImage(design: design) else {
            return nil
        }
        return image.pngData()
    }
    
    /// JPEG 형식으로 내보내기
    func exportAsJPEG(design: Design, quality: CGFloat = 0.9) -> Data? {
        guard let image = renderDesignAsImage(design: design) else {
            return nil
        }
        return image.jpegData(compressionQuality: quality)
    }
    
    /// 이미지를 파일로 저장
    func saveImageToDocuments(imageData: Data, filename: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    // MARK: - Share Sheet
    
    /// iOS 공유 시트용 Activity Items 생성
    func createShareItems(for design: Design, format: ExportFormat = .png) -> [Any] {
        var items: [Any] = []
        
        // 이미지 추가
        if let imageData = format == .png ? exportAsPNG(design: design) : exportAsJPEG(design: design),
           let image = UIImage(data: imageData) {
            items.append(image)
        }
        
        // 프로젝트 정보 텍스트
        let text = """
        Yena's Fit Studio
        디자인: \(design.name)
        레이어: \(design.layers.count)개
        """
        items.append(text)
        
        return items
    }
}

enum ExportFormat {
    case png
    case jpeg
    
    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpeg: return "jpg"
        }
    }
    
    var mimeType: String {
        switch self {
        case .png: return "image/png"
        case .jpeg: return "image/jpeg"
        }
    }
}
