# 🌳 숲코몽 (soopkomong)
**"발걸음으로 채워가는 나만의 푸른 숲"**

숲코몽은 일상 속의 단순한 걷기를 즐거운 모험으로 바꾸어주는 **위치 기반 캐릭터 수집 소셜 앱**입니다. 실제 공원을 탐험하여 새로운 구역의 방문을 인증하고, 걸음수를 모아 신비로운 숲 캐릭터를 수집하며 친구들과 함께 건강한 습관을 만들어가는 경험을 선사합니다.

---

## 🛠️ Tech Stack & Libraries

### Environment
- **Framework:** Flutter
- **Language:** Dart

### Libraries & Backend
- **State Management:** `flutter_riverpod` - 전역 상태 관리 및 의존성 주입을 통한 선언적 로직 제어
- **Navigation:** `go_router` - 딥링크 및 선언적 라우팅 관리
- **Backend & Auth:**
    * `firebase_core`, `cloud_firestore` - 실시간 유저 데이터 및 공원/캐릭터 정보 동기화
    * `firebase_auth`, `google_sign_in`, `kakao_flutter_sdk`, `sign_in_with_apple` - 다중 소셜 로그인 지원
    * `firebase_storage` - 유저 프로필 및 캐릭터 미디어 에셋 관리
    * `firebase_messaging` - 친구 요청 및 활동 알림 (FCM)
- **Maps & Sensors:**
    * `mapbox_maps_flutter`, `kakao_flutter_sdk` (Webview) - 위치 기반 공원 탐색 및 지도 인터페이스
    * `geolocator` - 실시간 위치 정보 기반 공원 방문 인증
    * `pedometer` - 하드웨어 센서 연동 실시간 걸음수 트래킹
- **UI & Experience:**
    * `flutter_svg`, `cached_network_image` - 벡터 그래픽 및 이미지 캐싱 최적화
    * `shimmer`, `flutter_slidable`, `fluttertoast` - UX 향상을 위한 인터랙션 및 피드백 컴포넌트

---

## 🚀 Key Features

### 1. 위치 기반 공원 탐험 (Park Discovery & Verification)
- **공원 탐색 레이어:** 사용자의 현재 위치를 중심으로 방문 가능한 주변 공원들을 실시간으로 시각화합니다.
- **방문 잠금 해제:** 실제 공원 구역 내에 진입 시 GPS 기반 인증을 통해 해당 위치의 보상을 획득하고 콘텐츠를 잠금 해제합니다.

### 2. 실시간 걸음수 트래킹 및 캐릭터 부화 (Walk-to-Hatch System)
- **백그라운드 센서 연동:** 앱이 꺼져 있어도 실시간으로 걸음수를 측정하여 에너지를 축적합니다.
- **신비로운 알 부화:** 일일 목표 걸음수를 달성하면 숲의 기운을 담은 알이 부화하여 새로운 숲코몽 캐릭터를 탄생시킵니다.

### 3. 숲 캐릭터 도감 및 컬렉션 (Forest Encyclopedia)
- **등급별 캐릭터 수집:** 수집한 캐릭터들을 등급별로 관리하고 나만의 숲 도감을 완성해나가는 즐거움을 제공합니다.
- **캐릭터 스토리:** 각 캐릭터가 가진 고유한 특성과 숲의 이야기를 확인할 수 있습니다.

### 4. 소셜 네트워크 및 친구 시스템 (Social Forest Connection)
- **친구 간 교류:** 친구의 숲 상태를 확인하고 활동 소식을 공유하며 함께 성장하는 커뮤니티를 형성합니다.
- **실시간 소통:** 친구 요청 및 중요 활동 정보를 푸시 알림을 통해 즉각적으로 전달받습니다.

---

## 📂 Project Structure

숲코몽은 **Clean Architecture** 원칙을 준수하여 각 레이어의 책임을 명확히 분리했습니다.

```text
lib/
├── core/                  # 앱 전역 설정 레이어
│   ├── router/            # GoRouter 기반 네비게이션 정의
│   ├── theme/             # Pretendard 기반 타이포그래피 및 디자인 시스템
│   └── utils/             # 공통 유틸리티 및 익스텐션
├── data/                  # 외부 통신 및 데이터 처리 레이어 (Data Source, Repositories)
├── domain/                # 순수 비즈니스 로직 및 엔티티 (Entities, Interfaces)
├── presentation/          # 기능별 UI 레이어 및 상태 관리 (Widgets, Pages, Providers)
│   ├── auth/              # 소셜 로그인 및 온보딩 서비스
│   ├── home/              # 맵 인터페이스 및 메인 대시보드
│   ├── explore/           # 공원 탐색 및 위치 기반 로직
│   ├── collection/        # 알 부화 및 캐릭터 도감 관리
│   ├── friends/           # 친구 목록 및 요청/알림 관리
│   └── mypage/            # 유저 프로필 및 설정 관리
└── main.dart              # 앱 진입점 및 초기화 (ProviderScope 설정)
```

---
<p align="center">
  <b>발자국이 모여 울창한 숲이 되는 곳, 숲코몽 🌳</b>
</p>
