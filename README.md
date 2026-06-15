# Coordi

옷 색상을 입력하면 나머지 카테고리에 어울리는 색상 조합을 추천해주는 Flutter 웹 앱.

---

## 주요 기능

### 색상 입력
- **색상환 탭**: HSV 색상환(HueRingPicker)으로 직접 선택
- **사진 추출 탭**: 갤러리 이미지에서 PaletteGenerator로 대표 색상 최대 6개 추출

### 다중 카테고리 입력
- 홈에서 카테고리 칩을 최대 6개까지 선택
- 카테고리별로 색상을 순차 입력 (단계 표시: `상의 색상 선택 2/3`)
- 다중 입력 시 교집합 색상을 우선 추천, 부족하면 첫 번째 입력 기준으로 보완
- 뒤로가기 시 이전 단계로 복귀 (이전에 선택한 색상 색상환에 복원)

### 포인트 카테고리 선택
- 마지막 색상 입력 단계에서 포인트 카테고리 지정 (기본값: 양말)
- 포인트 카테고리는 채도 높은 유채색을 우선 추천
- 추천 결과에서 해당 카테고리에 ✨ 포인트 배지 표시

### 추천 알고리즘
- 입력 색상 → 12개 기준 색상(HSV 매핑) → 매칭 규칙 조회
- 등급: excellent(92%) / good(80%) / okay(65%)
- 카테고리별 오프셋 균등 분배로 중복 없이 다양한 색상 배정
- 입력으로 사용된 카테고리는 추천 대상에서 제외

---

## 화면 구성

```
HomeScreen
└─ 카테고리 멀티셀렉트 다이얼로그 (최대 6개)
   └─ ColorPickerScreen (카테고리별 순차 입력)
      ├─ 색상환 탭
      ├─ 사진 추출 탭
      └─ 포인트 카테고리 선택 (마지막 단계)
         └─ RecommendationScreen (추천 결과)
```

---

## 기준 색상 (12종)

| 계열 | 색상 |
|------|------|
| 무채색 | white, black, gray, beige |
| 어두운 유채색 | navy, brown, khaki |
| 밝은 유채색 | red, pink, yellow, green, lightBlue |

---

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/
│   │   ├── clothing_category.dart     # 7개 카테고리 enum
│   │   ├── color_harmony_type.dart    # 조화 타입 enum
│   │   └── achromatic_helper.dart     # 무채색 판별 유틸
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── home/presentation/
│   │   └── home_screen.dart           # 카테고리 멀티셀렉트
│   ├── color_picker/
│   │   ├── presentation/
│   │   │   └── color_picker_screen.dart  # 다중 단계 색상 입력 + 포인트 선택
│   │   └── providers/
│   │       └── color_picker_provider.dart
│   └── recommendation/
│       ├── domain/
│       │   ├── color_recommendation.dart         # 추천 결과 모델
│       │   ├── color_recommendation_service.dart # 추천 알고리즘
│       │   ├── color_suggestion.dart             # 단일 추천 항목 모델
│       │   └── reference_colors.dart             # 기준 색상 + 매칭 규칙
│       ├── presentation/
│       │   └── recommendation_screen.dart        # 추천 결과 표시
│       └── providers/
│           └── recommendation_provider.dart
└── shared/widgets/
    └── category_card.dart
```

---

## 실행

```bash
flutter pub get
flutter run -d chrome
```

Flutter 3.27 이상 권장 (`Color.r/g/b` double API 사용).

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

| 분류 | 케이스 | 검증 내용 |
|------|--------|----------|
| 위젯 | 홈 화면 렌더링 | AppBar 로고, 카테고리 그리드 표시 여부 |
| 위젯 | 다이얼로그 열림 | 카테고리 탭 시 멀티셀렉트 다이얼로그 진입 |
| 서비스 | 단일 입력 | 입력 카테고리 제외 후 추천 대상 6개 |
| 서비스 | 다중 입력 | 입력 수만큼 추천 대상 감소 |
| 서비스 | 추천 수 | 카테고리별 최대 3개 이하 |
| 서비스 | 포인트 카테고리 | 지정 카테고리가 결과에 포함 |
| 서비스 | 6개 입력 | 추천 대상 1개 |
| 서비스 | 7개 입력(전체) | 빈 결과 반환, 크래시 없음 |
| 서비스 | 교집합 우선 | 다중 입력 공통 매칭 색상이 결과에 포함 |
