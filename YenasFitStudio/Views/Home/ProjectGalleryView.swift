//
//  ProjectGalleryView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import SwiftUI

struct ProjectGalleryView: View {
    let projects: [Project]
    
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(projects) { project in
                ProjectCard(project: project)
            }
        }
        .padding(.horizontal)
    }
}

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            // 썸네일
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "paintbrush.pointed.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("디자인 \(project.designs.count)개")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
            
            // 프로젝트 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                
                HStack {
                    Text(project.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    Text(project.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#if DEBUG
struct ProjectGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProjects = [
            Project(name: "여름 컬렉션", category: .womenswear),
            Project(name: "스트리트 패션", category: .unisex),
            Project(name: "정장 라인", category: .menswear)
        ]
        
        ProjectGalleryView(projects: sampleProjects)
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
