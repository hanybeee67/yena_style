# Yena's Fit Studio

AI 기반 패션 디자인 & 패턴 제작 iPad 앱

## 프로젝트 개요

청강대 스타일리스트과 학생을 위한 패션 디자인 앱으로, AI를 활용한 디자인 생성과 애플펜슬 기반 세밀한 수정, 실제 제작을 위한 패턴 도출까지 지원하는 올인원 툴입니다.

## 기술 스택

- **플랫폼**: iPad Pro (iOS 16.0+)
- **개발 도구**: Xcode 14+
- **언어**: Swift 5.7+
- **프레임워크**: SwiftUI, PencilKit

## 주요 기능

### 1. 메인 홈 (Dashboard)
- 프로젝트 갤러리
- 새 프로젝트 시작 (남성복/여성복/유니섹스)
- 영감 보드

### 2. 디자인 워크스페이스
- **중앙 캔버스**: 애플펜슬 드로잉 + AI 생성 디자인
- **레이어 시스템**: 포토샵 스타일의 다중 레이어
- **드로잉 툴**: 펜, 연필, 마커, 지우개
- **AI 프롬프트**: 텍스트로 디자인 생성
- **속성 패널**: 원단, 색상, 패턴 선택

### 3. 패턴 룸
- 도식화 (평면도) 생성
- 봉제선 가이드
- 치수 입력
- PDF 작업지시서 내보내기

### 4. 고급 기능
- 무드보드 사이드바
- 자동 색상 팔레트 추출
- 텍스처 오버레이

## 개발 단계

### Phase 1: MVP (2-3주)
- ✅ 기본 UI 구조
- ✅ PencilKit 드로잉
- ✅ 레이어 시스템
- ✅ 로컬 텍스처 적용

### Phase 2: AI 통합 (2-3주)
- ⬜ AI API 연동
- ⬜ 텍스트 to 이미지 생성
- ⬜ 스타일 트랜스퍼

### Phase 3: 고급 기능 (2-4주)
- ⬜ 패턴 생성
- ⬜ 무드보드
- ⬜ 색상 추출
- ⬜ PDF 내보내기

## 시작하기

### 1. Xcode 프로젝트 생성

```bash
# Xcode에서:
# File > New > Project
# iOS > App 선택
# Product Name: YenasFitStudio
# Interface: SwiftUI
# Language: Swift
```

### 2. 필요한 권한 설정

`Info.plist`에 다음 추가:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>영감 보드에 이미지를 추가하기 위해 사진 라이브러리 접근이 필요합니다.</string>
```

### 3. 프로젝트 구조

```
YenasFitStudio/
├── App/
│   ├── YenasFitStudioApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Project.swift
│   ├── Design.swift
│   ├── Layer.swift
│   └── Fabric.swift
├── Views/
│   ├── Home/
│   ├── Workspace/
│   └── Pattern/
├── Components/
│   ├── Drawing/
│   ├── UI/
│   └── MoodBoard/
├── Services/
│   ├── AIService.swift
│   ├── ImageProcessor.swift
│   ├── ColorExtractor.swift
│   └── DataManager.swift
└── Resources/
    ├── Fabrics/
    ├── Templates/
    └── Patterns/
```

## 참고 자료

- [Apple Developer - PencilKit](https://developer.apple.com/documentation/pencilkit)
- [Hacking with Swift - SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui)
- [Replicate - Stable Diffusion](https://replicate.com/stability-ai/stable-diffusion)
- [OpenAI - DALL-E API](https://platform.openai.com/docs/guides/images)

## 라이센스

개인 프로젝트
