//
//  DashboardView.swift
//  Yena's Fit Studio
//
//  Created on 2026-02-08.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingNewProjectSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 새 프로젝트 버튼
                    Button(action: {
                        showingNewProjectSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                            Text("새 프로젝트 시작")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // 프로젝트 갤러리
                    Text("내 포트폴리오")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    if dataManager.projects.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("아직 프로젝트가 없습니다")
                                .foregroundColor(.secondary)
                            Text("위의 버튼을 눌러 첫 프로젝트를 시작하세요!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ProjectGalleryView(projects: dataManager.projects)
                    }
                    
                    // 영감 보드
                    Text("영감 보드")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    InspirationBoardView()
                }
                .padding(.top)
            }
            .navigationTitle("Yena's Fit Studio")
            .sheet(isPresented: $showingNewProjectSheet) {
                NewProjectSheet()
            }
        }
    }
}

struct NewProjectSheet: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var projectName = ""
    @State private var selectedCategory: Project.Category = .womenswear
    
    var body: some View {
        NavigationView {
            Form {
                Section("프로젝트 정보") {
                    TextField("프로젝트 이름", text: $projectName)
                    
                    Picker("카테고리", selection: $selectedCategory) {
                        ForEach(Project.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("바디 템플릿") {
                    Text("기본 템플릿이 사용됩니다")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("새 프로젝트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("생성") {
                        createProject()
                    }
                    .disabled(projectName.isEmpty)
                }
            }
        }
    }
    
    private func createProject() {
        let project = Project(name: projectName, category: selectedCategory)
        dataManager.createProject(project)
        dismiss()
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(DataManager())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
