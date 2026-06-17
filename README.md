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

---

## 화면 구성

```
HomeScreen (상의·하의·아우터 리스트)
└─ 카테고리 멀티셀렉트 다이얼로그 (최대 3개)
   └─ ColorPickerScreen (카테고리별 순차 입력)
      ├─ 색상환 탭 (HSVColor 직접 처리)
      ├─ 사진 추출 탭
      └─ 포인트 카테고리 선택 (마지막 단계)
         └─ RecommendationScreen (추천 결과)
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
│   │   └── home_screen.dart              # 카테고리 리스트 + 멀티셀렉트 다이얼로그
│   ├── color_picker/
│   │   ├── presentation/
│   │   │   └── color_picker_screen.dart  # 다중 단계 색상 입력 + 포인트 선택
│   │   └── providers/
│   │       └── color_picker_provider.dart  # wheelColorProvider: HSVColor
│   └── recommendation/
│       ├── domain/
│       │   ├── color_recommendation.dart          # 추천 결과 모델
│       │   ├── color_recommendation_service.dart  # 추천 알고리즘
│       │   ├── color_suggestion.dart              # 단일 추천 항목 모델
│       │   └── reference_colors.dart              # 18색 기준 + 매칭 규칙 + HSV 매핑
│       ├── presentation/
│       │   └── recommendation_screen.dart         # 추천 결과 표시
│       └── providers/
│           └── recommendation_provider.dart
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

---

## 주요 변경 이력

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
