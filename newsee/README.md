# newsee

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

lib/
├── main.dart                  // 앱의 진입점
├── core/                      // 핵심 기능 폴더
│   ├── constants/             // 상수값 정의 (API 키, URL 등)
│   ├── error/                 // 에러 및 예외 처리
│   ├── utils/                 // 유틸리티 함수들 (날짜 변환 등)
│   └── theme/                 // 앱 전체 테마 설정
├── data/                      // 데이터 관련 폴더
│   ├── models/                // 데이터 모델 정의
│   ├── repositories/          // 저장소 (Repository) 정의
│   └── providers/             // 데이터 상태 관리 (Provider) 
├── domain/                    // 비즈니스 로직 및 엔티티 폴더
│   ├── entities/              // 앱의 주요 개체 정의
│   └── usecases/              // 비즈니스 로직 처리 함수들
├── presentation/              // UI 관련 폴더
│   ├── pages/                 // 각 화면에 대한 위젯
│   ├── widgets/               // 재사용 가능한 공통 위젯들
│   └── navigation/            // 네비게이션 설정
└── config/                    // 설정 파일 폴더
    ├── app_config.dart        // 앱 전역 설정
    └── routes.dart            // 네비게이션 경로 설정
