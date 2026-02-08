//
//  ShareSheet.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//  UIActivityViewController를 SwiftUI에서 사용하기 위한 래퍼
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let onDismiss: (() -> Void)?
    
    init(items: [Any], onDismiss: (() -> Void)? = nil) {
        self.items = items
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss?()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
