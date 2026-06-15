// HSV 기반 무채색(뉴트럴) 판별 헬퍼.
// Flutter HSVColor: hue 0–360, saturation 0–1, value 0–1

enum AchromaticType {
  black('블랙'),
  white('화이트'),
  gray('그레이'),
  navy('네이비'),
  beige('베이지');

  const AchromaticType(this.label);

  final String label;
}

abstract final class AchromaticHelper {
  // 무채색 판별 HSV 범위:
  //   Black : V < 0.20
  //   White : S < 0.10 && V > 0.85
  //   Gray  : S < 0.15  (0.20 ≤ V ≤ 0.85)
  //   Navy  : H 200–240, S ≥ 0.40, V ≤ 0.35  (짙은 청색계)
  //   Beige : H 25–55,   S 0.08–0.35, V ≥ 0.70  (따뜻한 오프화이트계)

  static bool isAchromatic(double hue, double saturation, double value) =>
      getType(hue, saturation, value) != null;

  static AchromaticType? getType(double hue, double saturation, double value) {
    if (value < 0.20) return AchromaticType.black;
    if (saturation < 0.10 && value > 0.85) return AchromaticType.white;
    if (saturation < 0.15) return AchromaticType.gray;
    if (hue >= 200 && hue <= 240 && saturation >= 0.40 && value <= 0.35) {
      return AchromaticType.navy;
    }
    if (hue >= 25 &&
        hue <= 55 &&
        saturation >= 0.08 &&
        saturation <= 0.35 &&
        value >= 0.70) {
      return AchromaticType.beige;
    }
    return null;
  }
}
