import 'package:flutter/material.dart';

// ─── 기준 색상 열거형 ────────────────────────────────────────────────────────────

enum ReferenceColor {
  white    (Color(0xFFF2F2F7), '화이트'),
  black    (Color(0xFF1C1C1E), '블랙'),
  beige    (Color(0xFFF5E6C8), '베이지'),
  navy     (Color(0xFF1C2B4A), '네이비'),
  gray     (Color(0xFF8E8E93), '그레이'),
  lightBlue(Color(0xFF90CAF9), '라이트블루'),
  khaki    (Color(0xFF6B7A4F), '카키'),
  red      (Color(0xFFD32F2F), '레드'),
  brown    (Color(0xFF8D6E63), '브라운'),
  pink     (Color(0xFFF48FB1), '핑크'),
  green    (Color(0xFF2E7D32), '그린'),
  yellow   (Color(0xFFFDD835), '옐로우'),
  cream    (Color(0xFFF5F0DC), '크림'),
  charcoal (Color(0xFF3A3A3C), '차콜'),
  denimBlue(Color(0xFF3F5872), '데님블루'),
  burgundy (Color(0xFF7B1E3D), '버건디'),
  purple   (Color(0xFF7E6B8F), '퍼플'),
  orange   (Color(0xFFF4791F), '오렌지');

  const ReferenceColor(this.color, this.label);
  final Color color;
  final String label;
}

// ─── 매칭 등급 / 매칭 항목 ──────────────────────────────────────────────────────

/// A+ = excellent, A = good, B = okay
enum MatchGrade { excellent, good, okay }

class ColorMatch {
  const ColorMatch(this.color, this.grade);
  final ReferenceColor color;
  final MatchGrade grade;
}

// ─── 패션 색상 매칭 규칙 ─────────────────────────────────────────────────────────
//
// 각 기준 색상별 "어울리는 색상 + 등급" 리스트.
// 목록 순서 = excellent → good → okay (서비스에서 정렬하지만 가독성을 위해 미리 정렬).

const Map<ReferenceColor, List<ColorMatch>> colorMatchingRules = {
  ReferenceColor.white: [
    ColorMatch(ReferenceColor.black,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.red,       MatchGrade.excellent),
    ColorMatch(ReferenceColor.brown,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.pink,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.green,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.charcoal,  MatchGrade.excellent),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.excellent),
    ColorMatch(ReferenceColor.purple,    MatchGrade.excellent),
    ColorMatch(ReferenceColor.orange,    MatchGrade.excellent),
  ],
  ReferenceColor.black: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.brown,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
  ],
  ReferenceColor.beige: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.black,     MatchGrade.good),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.red,       MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
    ColorMatch(ReferenceColor.orange,    MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.okay),
  ],
  ReferenceColor.navy: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
  ],
  ReferenceColor.gray: [
    ColorMatch(ReferenceColor.white,     MatchGrade.good),
    ColorMatch(ReferenceColor.beige,     MatchGrade.good),
    ColorMatch(ReferenceColor.black,     MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
  ],
  ReferenceColor.lightBlue: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
    ColorMatch(ReferenceColor.red,       MatchGrade.good),
    ColorMatch(ReferenceColor.purple,    MatchGrade.good),
  ],
  ReferenceColor.khaki: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
  ],
  ReferenceColor.red: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
  ],
  ReferenceColor.brown: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.black,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.good),
    ColorMatch(ReferenceColor.orange,    MatchGrade.good),
  ],
  ReferenceColor.pink: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.black,     MatchGrade.good),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
    ColorMatch(ReferenceColor.red,       MatchGrade.okay),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.okay),
  ],
  ReferenceColor.green: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.good),
    ColorMatch(ReferenceColor.orange,    MatchGrade.good),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
  ],
  ReferenceColor.yellow: [
    ColorMatch(ReferenceColor.black,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.white,     MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
  ],
  ReferenceColor.cream: [
    ColorMatch(ReferenceColor.black,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.excellent),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.orange,    MatchGrade.good),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.good),
  ],
  ReferenceColor.charcoal: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.pink,      MatchGrade.good),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.burgundy,  MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.yellow,    MatchGrade.okay),
  ],
  ReferenceColor.denimBlue: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.khaki,     MatchGrade.good),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
    ColorMatch(ReferenceColor.black,     MatchGrade.good),
  ],
  ReferenceColor.burgundy: [
    ColorMatch(ReferenceColor.cream,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.beige,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.denimBlue, MatchGrade.good),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.black,     MatchGrade.good),
    ColorMatch(ReferenceColor.white,     MatchGrade.good),
    ColorMatch(ReferenceColor.pink,      MatchGrade.okay),
  ],
  ReferenceColor.purple: [
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.gray,      MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.good),
    ColorMatch(ReferenceColor.orange,    MatchGrade.good),
    ColorMatch(ReferenceColor.beige,     MatchGrade.good),
  ],
  ReferenceColor.orange: [
    ColorMatch(ReferenceColor.lightBlue, MatchGrade.excellent),
    ColorMatch(ReferenceColor.white,     MatchGrade.excellent),
    ColorMatch(ReferenceColor.navy,      MatchGrade.good),
    ColorMatch(ReferenceColor.cream,     MatchGrade.good),
    ColorMatch(ReferenceColor.green,     MatchGrade.good),
    ColorMatch(ReferenceColor.brown,     MatchGrade.good),
  ],
};

// ─── 색상 매핑 함수 ──────────────────────────────────────────────────────────────

/// 입력 [Color]를 18개 기준 색상 중 가장 가까운 [ReferenceColor]로 매핑한다.
///
/// 판별 우선순위:
///   1. 명도/채도 기반 무채색: black → charcoal → cream → white → gray
///   2. warm 저채도: beige
///   3. 어두운 유채색: burgundy → denimBlue → navy → orange → brown → khaki
///   4. purple (hue 고정 범위)
///   5. hue 거리 기반 밝은 유채색: red / pink / yellow / green / lightBlue
ReferenceColor mapToReference(Color input) {
  final hsv = HSVColor.fromColor(input);
  final h   = hsv.hue;
  final s   = hsv.saturation;
  final v   = hsv.value;

  // ── 무채색 계열 ──────────────────────────────────────────────────────────
  if (v < 0.20) return ReferenceColor.black;

  // charcoal: black과 gray 사이 어두운 무채색 (v 0.20~0.38, s < 0.12)
  if (v <= 0.38 && s < 0.12) return ReferenceColor.charcoal;

  // cream: 매우 밝고 warm한 저채도 (beige보다 더 밝은 영역)
  if (h >= 20 && h <= 60 && s < 0.12 && v >= 0.92) return ReferenceColor.cream;

  if (s < 0.10 && v > 0.85) return ReferenceColor.white;
  if (s < 0.15) return ReferenceColor.gray;

  // warm + desaturated + bright → beige
  if (h >= 22 && h <= 55 && s <= 0.35 && v >= 0.65) return ReferenceColor.beige;

  // ── 어두운 유채색 ────────────────────────────────────────────────────────
  // burgundy: 어두운 레드/와인 (red보다 낮은 명도) — red보다 먼저 체크
  if ((h >= 340 || h <= 10) && s >= 0.30 && v < 0.50) return ReferenceColor.burgundy;

  // denimBlue: 중간 명도 파랑 (navy와 lightBlue 사이) — navy보다 먼저 체크
  // 상한을 0.68로 설정: HSV→RGB→HSV 부동소수점 왕복 오차(≈0.001~0.002) 흡수
  if (h >= 200 && h <= 235 && s >= 0.25 && v >= 0.30 && v < 0.68) {
    return ReferenceColor.denimBlue;
  }

  // navy: 어두운 파랑 전반 (denimBlue 제외 후 나머지 어두운 파랑)
  if (h >= 195 && h <= 255 && s >= 0.30 && v <= 0.50) return ReferenceColor.navy;

  // orange: warm-orange, 높은 채도 (brown보다 밝고 채도 높음) — brown보다 먼저 체크
  if (h >= 15 && h <= 45 && s >= 0.50 && v >= 0.45) return ReferenceColor.orange;

  // warm dark (red-orange range, 낮은 명도, 중간 채도) → brown
  if (h < 35 && s >= 0.15 && s <= 0.60 && v >= 0.25 && v < 0.65) {
    return ReferenceColor.brown;
  }
  if (h >= 35 && h < 55 && v < 0.55 && s < 0.55) return ReferenceColor.brown;

  // yellow-green, 낮은 명도 → khaki
  if (h >= 65 && h < 105 && v < 0.62) return ReferenceColor.khaki;

  // purple: 보라 계열 (hue 250~290)
  if (h >= 250 && h <= 290) return ReferenceColor.purple;

  // ── 밝은 유채색: hue 거리 최소 기준 ─────────────────────────────────────
  //   기준 hue 각도: red=0°, pink=338°, yellow=50°, green=123°, lightBlue=208°
  const refs = [
    (ReferenceColor.red,         0.0),
    (ReferenceColor.pink,      338.0),
    (ReferenceColor.yellow,     50.0),
    (ReferenceColor.green,     123.0),
    (ReferenceColor.lightBlue, 208.0),
  ];

  var best     = ReferenceColor.red;
  var bestDist = double.infinity;
  for (final (ref, refH) in refs) {
    final d = _hueDist(h, refH);
    if (d < bestDist) {
      bestDist = d;
      best = ref;
    }
  }
  return best;
}

double _hueDist(double a, double b) {
  final d = (a - b).abs();
  return d > 180 ? 360 - d : d;
}
