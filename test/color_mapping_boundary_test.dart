import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';

// HSVColor → Color → mapToReference 헬퍼
ReferenceColor fromHSV(double h, double s, double v) =>
    mapToReference(HSVColor.fromAHSV(1.0, h, s, v).toColor());

void main() {
  // ─── 1. burgundy vs red 경계 (v 기준 0.50) ──────────────────────────────────
  group('burgundy vs red (h=0, s=0.80)', () {
    test('v=0.45 → burgundy', () {
      expect(fromHSV(0, 0.80, 0.45), ReferenceColor.burgundy);
    });
    test('v=0.49 → burgundy (경계 직전)', () {
      expect(fromHSV(0, 0.80, 0.49), ReferenceColor.burgundy);
    });
    test('v=0.50 → red (경계 이탈)', () {
      expect(fromHSV(0, 0.80, 0.50), ReferenceColor.red);
    });
    test('v=0.55 → red', () {
      expect(fromHSV(0, 0.80, 0.55), ReferenceColor.red);
    });
    test('v=0.83 → red (대표 레드 명도)', () {
      expect(fromHSV(0, 0.78, 0.83), ReferenceColor.red);
    });
    // h=340 쪽 버건디도 확인
    test('h=350, v=0.40 → burgundy', () {
      expect(fromHSV(350, 0.60, 0.40), ReferenceColor.burgundy);
    });
    test('h=350, v=0.55 → red (hue 거리 우선)', () {
      expect(fromHSV(350, 0.60, 0.55), ReferenceColor.red);
    });
  });

  // ─── 2. purple — 저채도 경계 ──────────────────────────────────────────────────
  group('purple 저채도 경계 (h=270)', () {
    test('s=0.08 → gray (s<0.15 먼저 걸림)', () {
      expect(fromHSV(270, 0.08, 0.60), ReferenceColor.gray);
    });
    test('s=0.14 → gray (경계 직전)', () {
      expect(fromHSV(270, 0.14, 0.60), ReferenceColor.gray);
    });
    test('s=0.16 → purple (gray 분기 통과)', () {
      expect(fromHSV(270, 0.16, 0.60), ReferenceColor.purple);
    });
    test('s=0.50 → purple (중간 채도)', () {
      expect(fromHSV(270, 0.50, 0.56), ReferenceColor.purple);
    });
    // 어두운 보라 → charcoal/navy 범위와 충돌 여부
    test('h=260, v=0.25, s=0.08 → charcoal (어둡고 무채색에 가까움)', () {
      expect(fromHSV(260, 0.08, 0.25), ReferenceColor.charcoal);
    });
    test('h=258, s=0.45, v=0.35 → navy (h<=255 경계 밖이라 purple?)', () {
      // h=258 은 navy(195~255) 범위 초과 → purple 로 빠질 것
      final result = fromHSV(258, 0.45, 0.35);
      // 예상값을 명시적으로 확인 후 주석
      expect(result, anyOf(ReferenceColor.purple, ReferenceColor.navy));
      debugPrint('h=258, s=0.45, v=0.35 → $result');
    });
  });

  // ─── 3. orange vs yellow 경계 (h=45 기준) ───────────────────────────────────
  group('orange vs yellow 경계', () {
    test('h=30, s=0.80, v=0.90 → orange', () {
      expect(fromHSV(30, 0.80, 0.90), ReferenceColor.orange);
    });
    test('h=44, s=0.70, v=0.90 → orange (경계 직전)', () {
      expect(fromHSV(44, 0.70, 0.90), ReferenceColor.orange);
    });
    test('h=45, s=0.70, v=0.90 → orange (경계값 포함)', () {
      expect(fromHSV(45, 0.70, 0.90), ReferenceColor.orange);
    });
    test('h=46, s=0.70, v=0.90 → yellow (hue 거리: 50°에 더 가까움)', () {
      expect(fromHSV(46, 0.70, 0.90), ReferenceColor.yellow);
    });
    test('h=50, s=0.80, v=0.97 → yellow (대표 노랑)', () {
      expect(fromHSV(50, 0.80, 0.97), ReferenceColor.yellow);
    });
    // s 조건 미달: h=30이어도 s<0.50 → orange 분기 탈락
    test('h=30, s=0.40, v=0.90 → brown 또는 yellow (s<0.50 탈락)', () {
      final result = fromHSV(30, 0.40, 0.90);
      // brown 1차 조건: h<35, s 0.15~0.60, v 0.25~0.65 → v=0.90 범위 초과
      // 결과는 hue 거리 → yellow(50°, dist=20) vs red(0°, dist=30) → yellow
      expect(result, anyOf(ReferenceColor.yellow, ReferenceColor.brown));
      debugPrint('h=30, s=0.40, v=0.90 → $result');
    });
  });

  // ─── 4. denimBlue vs lightBlue 경계 (v=0.65~0.70) ──────────────────────────
  group('denimBlue vs lightBlue 경계 (h=210, s=0.40)', () {
    test('v=0.50 → denimBlue', () {
      expect(fromHSV(210, 0.40, 0.50), ReferenceColor.denimBlue);
    });
    test('v=0.65 → denimBlue (float 오차 흡수, 상한 0.68)', () {
      expect(fromHSV(210, 0.40, 0.65), ReferenceColor.denimBlue);
    });
    test('v=0.67 → denimBlue (상한 0.68 직전)', () {
      expect(fromHSV(210, 0.40, 0.67), ReferenceColor.denimBlue);
    });
    test('v=0.70 → lightBlue (상한 이탈)', () {
      expect(fromHSV(210, 0.40, 0.70), ReferenceColor.lightBlue);
    });
    test('v=0.976 → lightBlue (대표 라이트블루 명도)', () {
      expect(fromHSV(207, 0.42, 0.976), ReferenceColor.lightBlue);
    });
    // denimBlue vs navy (v 하한)
    test('v=0.30 → denimBlue (하한 경계값)', () {
      expect(fromHSV(210, 0.40, 0.30), ReferenceColor.denimBlue);
    });
    test('v=0.29 → navy (하한 미달 → navy로)', () {
      expect(fromHSV(210, 0.40, 0.29), ReferenceColor.navy);
    });
  });

  // ─── 5. 대표 색상 자기 매핑 검증 ─────────────────────────────────────────────
  group('ReferenceColor 대표값 자기 매핑', () {
    for (final ref in ReferenceColor.values) {
      test('${ref.name} → ${ref.name}', () {
        final result = mapToReference(ref.color);
        if (result != ref) {
          debugPrint('[MISMATCH] ${ref.name} (#${ref.color.value.toRadixString(16)}) → ${result.name}');
        }
        expect(result, ref);
      });
    }
  });
}
