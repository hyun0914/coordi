# Coordi

옷 색상을 입력하면 나머지 카테고리에 어울리는 색상 조합을 추천해주는 Flutter 웹 앱.

---

## 주요 기능

### 색상 입력
- **색상환 탭**: `ColorPickerHueRing` + `ColorPickerArea`를 직접 조합하여 HSVColor end-to-end 처리
  - 흰색·검정 구역에서도 hue가 손실되지 않음 (Color 변환 없음)
- **사진 추출 탭**: 갤러리 이미지에서 PaletteGenerator로 대표 색상 최대 6개 추출

### 카테고리 구분
- **기준 색상 입력 대상** (isMain): 상의 / 하의 / 아우터
- **추천 결과 대상** (accessories): 신발 / 양말 / 모자 / 가방
- 홈 화면에서 상의·하의·아우터만 선택 가능, 액세서리는 항상 추천 대상

### 다중 카테고리 입력
- 상의·하의·아우터 중 색상을 아는 항목을 1~3개 선택
- 카테고리별 색상 순차 입력 (단계 표시: `상의 색상 선택 2/3`)
- 다중 입력 시 교집합 색상 우선 추천, 부족하면 첫 번째 입력으로 보완
- 뒤로가기 시 이전 단계로 복귀 (이전 색상 색상환에 복원)

### 포인트 카테고리 선택
- 마지막 입력 단계에서 포인트 카테고리 지정 (기본값: 양말)
- 포인트 카테고리는 채도 높은 유채색 우선 추천
- 추천 결과에서 해당 카테고리에 ✨ 포인트 배지 표시

### 추천 알고리즘
- 입력 색상 → 18개 기준 색상(HSV 매핑) → 매칭 규칙 조회
- 등급: excellent(92%) / good(80%) / okay(65%)
- 카테고리별 오프셋 균등 분배로 중복 없이 다양한 색상 배정
- 입력으로 사용된 카테고리는 추천 대상에서 제외

### 계절 톤
- 홈에서 전체 / 봄 / 여름 / 가을 / 겨울 선택 (색상 피커·프리셋·옷장 추천에 모두 적용)
- 계절별 톤 색상 6종을 정의하고, 매칭 결과를 해당 톤 색상 위주로 좁힘
  - 톤 색상이 5개 미만이면 등급이 좋은 다른 색상으로 5개까지 보충 (카테고리 간 색상 반복 방지)
- "전체"는 계절 구분 없는 기존 추천과 동일
- 계절이 적용된 추천 결과에는 `가을 톤` 배지 표시
- 선택은 저장되지 않으며 앱을 새로 열면 "전체"로 돌아감

### 컬러 조합 프리셋
- 홈 "무드로 시작하기"에서 프리셋을 누르면 색상 피커 없이 바로 추천
- 8종: 모노톤, 어스톤, 네이비 × 옐로우, 소프트 블루, 데님 캐주얼, 버건디 클래식, 카키 × 네이비, 핑크 × 그레이
- 프리셋 = 상의/하의(/아우터) 기준 색 조합, 나머지 카테고리는 추천 알고리즘이 그대로 처리

### 내 옷장
- 카테고리별로 보유한 옷의 색상만 등록 (기준 색상 18종 중 선택, 사진·개별 아이템 없음)
- 추천 결과에서 같은 카테고리·같은 색상을 보유하고 있으면 카드에 `보유` 표시
- "내 옷장 색으로 코디 추천": 보유한 상의/하의/아우터 색상에서 무작위로 골라 추천

### 즐겨찾기 / 이미지 내보내기
- 추천 결과 화면에서 하트로 저장·해제, 즐겨찾기 화면에서 다시 열기·삭제(실행취소)
- 추천 결과 전체(스크롤 밖 영역 포함)를 PNG로 내보내기
  - Web Share API 미지원 브라우저에서는 파일 다운로드로 대체

### 데이터 저장
- 즐겨찾기와 옷장은 `shared_preferences`로 브라우저 localStorage에만 저장 (서버 전송 없음)
- 브라우저 데이터를 지우거나 다른 기기·브라우저에서는 보이지 않음

---

## 화면 구성

```
HomeScreen
├─ 계절 톤 선택 (전체/봄/여름/가을/겨울)
├─ 상의·하의·아우터 리스트
│  └─ 카테고리 멀티셀렉트 다이얼로그 (최대 3개)
│     └─ ColorPickerScreen (카테고리별 순차 입력)
│        ├─ 색상환 탭 (HSVColor 직접 처리)
│        ├─ 사진 추출 탭
│        └─ 포인트 카테고리 선택 (마지막 단계)
│           └─ RecommendationScreen
├─ 무드로 시작하기 (프리셋 8종)
│  └─ RecommendationScreen
├─ [앱바] WardrobeScreen (내 옷장)
│  ├─ 카테고리별 색상 선택 시트
│  └─ 내 옷장 색으로 코디 추천 → RecommendationScreen
└─ [앱바] FavoritesScreen (즐겨찾기)
   └─ RecommendationScreen (저장된 결과)

RecommendationScreen (추천 결과)
└─ [앱바] 즐겨찾기 저장/해제, 이미지로 내보내기
```

---

## 기준 색상 (18종)

| 계열 | 색상 |
|------|------|
| 무채색 | white `#F2F2F7`, black `#1C1C1E`, gray `#8E8E93` |
| 밝은 뉴트럴 | beige `#F5E6C8`, cream `#F5F0DC` |
| 어두운 뉴트럴 | charcoal `#3A3A3C` |
| 어두운 유채색 | navy `#1C2B4A`, brown `#8D6E63`, khaki `#6B7A4F` |
| 중간 파랑 | denimBlue `#3F5872` |
| 밝은 유채색 | lightBlue `#90CAF9`, red `#D32F2F`, pink `#F48FB1`, green `#2E7D32`, yellow `#FDD835` |
| 딥 컬러 | burgundy `#7B1E3D`, purple `#7E6B8F`, orange `#F4791F` |

### HSV 매핑 우선순위

```
black (v<0.20) → charcoal (v≤0.38, s<0.12) → cream (h 20-60, s<0.12, v≥0.92)
→ white (s<0.10, v>0.85) → gray (s<0.15) → beige (h 22-55, s≤0.35, v≥0.65)
→ burgundy (h 340-360/0-10, s≥0.30, v<0.50) → denimBlue (h 200-235, s≥0.25, v 0.30-0.68)
→ navy (h 195-255, s≥0.30, v≤0.50) → orange (h 15-45, s≥0.50, v≥0.45)
→ brown → khaki → purple (h 250-290) → hue 거리 기반 (red/pink/yellow/green/lightBlue)
```

---

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/
│   │   ├── clothing_category.dart        # 7개 카테고리 enum (isMain 구분)
│   │   ├── color_harmony_type.dart       # 조화 타입 enum
│   │   └── achromatic_helper.dart        # 무채색 판별 유틸
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── home/presentation/
│   │   └── home_screen.dart              # 계절 톤 선택 + 카테고리 리스트 + 프리셋
│   ├── color_picker/
│   │   ├── presentation/
│   │   │   └── color_picker_screen.dart  # 다중 단계 색상 입력 + 포인트 선택
│   │   └── providers/
│   │       └── color_picker_provider.dart  # wheelColorProvider: HSVColor
│   ├── recommendation/
│   │   ├── domain/
│   │   │   ├── color_presets.dart                 # 컬러 조합 프리셋 8종
│   │   │   ├── color_recommendation.dart          # 추천 결과 모델 (JSON 직렬화)
│   │   │   ├── color_recommendation_service.dart  # 추천 알고리즘 + 계절 톤 적용
│   │   │   ├── color_suggestion.dart              # 단일 추천 항목 모델 (JSON 직렬화)
│   │   │   ├── reference_colors.dart              # 18색 기준 + 매칭 규칙 + HSV 매핑
│   │   │   └── season.dart                        # 계절 enum + 계절별 톤 색상
│   │   ├── presentation/
│   │   │   └── recommendation_screen.dart         # 추천 결과 + 즐겨찾기/내보내기
│   │   └── providers/
│   │       └── recommendation_provider.dart       # seasonProvider
│   ├── favorites/
│   │   ├── domain/
│   │   │   └── saved_coordi.dart                  # 저장된 추천 결과 모델
│   │   ├── presentation/
│   │   │   └── favorites_screen.dart              # 즐겨찾기 목록
│   │   └── providers/
│   │       └── favorites_provider.dart            # 로컬 저장 (favorites_v1)
│   └── wardrobe/
│       ├── domain/
│       │   └── wardrobe.dart                      # 카테고리별 보유 색상 + 랜덤 입력 생성
│       ├── presentation/
│       │   └── wardrobe_screen.dart               # 내 옷장 + 색상 선택 시트
│       └── providers/
│           └── wardrobe_provider.dart             # 로컬 저장 (wardrobe_v1)
└── shared/widgets/
    └── category_card.dart                # 가로 리스트 카드 (아이콘 + 라벨 + 설명)
```

---

## 실행

```bash
flutter pub get
flutter run -d chrome
```

Flutter 3.27 이상 권장 (`Color.r/g/b` double API 사용).

웹 전용 프로젝트입니다 (`android/`, `ios/` 없음).
즐겨찾기·옷장은 origin(포트 포함)별 localStorage에 저장되므로, 개발 중 재실행 간 데이터를 유지하려면 포트를 고정하세요.

```bash
flutter run -d chrome --web-port=5000
```

---

## 배포 (Firebase Hosting)

```bash
flutter build web
firebase deploy --only hosting
```

**라이브 URL**: https://coordi-d1339.web.app

---

## 테스트

```bash
flutter test
```

### color_mapping_boundary_test.dart

| 그룹 | 케이스 | 검증 내용 |
|------|--------|----------|
| burgundy vs red | v=0.45/0.49 → burgundy | v<0.50 경계 |
| burgundy vs red | v=0.50/0.55 → red | burgundy 조건 이탈 |
| purple 저채도 | s=0.14 → gray | s<0.15 분기 먼저 적용 |
| purple 저채도 | s=0.16 → purple | gray 분기 통과 후 purple |
| orange vs yellow | h=45 → orange, h=46 → yellow | h=45 포함 경계 |
| denimBlue vs lightBlue | v=0.65/0.67 → denimBlue | float 오차 흡수 (상한 0.68) |
| denimBlue vs navy | v=0.30 → denimBlue, v=0.29 → navy | 하한 경계 |
| 자기 매핑 | 18색 전체 | 대표 HEX → 자기 자신으로 매핑 |

### 그 외 테스트 파일

| 파일 | 검증 내용 |
|------|----------|
| `widget_test.dart` | 홈 화면 렌더링, 카테고리 다이얼로그, 추천 서비스 기본 동작 |
| `favorites_test.dart` | 추천 결과 JSON 왕복, 재시작 후 복원, 삭제/실행취소, 깨진 데이터 건너뛰기 |
| `recommendation_screen_test.dart` | 하트 저장 → 즐겨찾기 화면 반영, 캡처 영역이 스크롤 밖까지 포함되는지 |
| `color_presets_test.dart` | 프리셋별 색상 매핑·추천 결과, 프리셋 → 추천 화면 이동, 좁은 화면 레이아웃 |
| `wardrobe_test.dart` | 옷장 저장/복원, 랜덤 입력 생성, 보유 표시, 좁은 화면 레이아웃 |
| `season_test.dart` | 계절 톤 필터링·보충 로직, 프리셋 × 계절 전 조합, 기존 저장 데이터 호환 |

이미지 내보내기의 실제 공유/다운로드 동작은 자동 테스트 대상이 아니므로 브라우저에서 직접 확인합니다.

---

## 주요 변경 이력

### 기능 확장
- 즐겨찾기(저장/목록/삭제 실행취소)와 PNG 이미지 내보내기 추가
- 컬러 조합 프리셋 8종 추가 (홈 "무드로 시작하기")
- 내 옷장 추가: 카테고리별 보유 색상 등록, 추천 카드 `보유` 표시, 옷장 색으로 랜덤 추천
- 계절 톤 필터 추가 (봄/여름/가을/겨울)
- 웹 전용으로 정리: `android/`, `ios/` 및 관련 Firebase 설정 제거

### 색상 데이터 확장
- 기준 색상 12개 → 18개 (cream, charcoal, denimBlue, burgundy, purple, orange 추가)
- colorMatchingRules 패션 자료 기반 전면 재작성
- mapToReference HSV 분기 확장, float 오차 흡수 처리

### UX / UI
- 색상환 피커: `HueRingPicker`(Color 기반) → `ColorPickerHueRing` + `ColorPickerArea` 직접 조합
  - `wheelColorProvider` 타입 `Color` → `HSVColor`로 변경
  - 흰색·검정 구역에서 링 포인터 hue 유지
- 밝은 색 원형(흰색·크림·베이지 등)에 테두리 자동 추가 (`computeLuminance > 0.85`)
- TabController 리스너 최적화 (`indexIsChanging` 가드로 불필요한 setState 제거)
- 홈 화면: 정사각형 그리드 → 가로 리스트 카드 (아이콘 + 설명 + 화살표)
- 카테고리 입력 범위: 전체 7개 → 상의·하의·아우터 3개 (액세서리는 추천 전용)
