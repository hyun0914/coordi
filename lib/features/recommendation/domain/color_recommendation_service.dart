import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/core/constants/color_harmony_type.dart';
import 'color_recommendation.dart';
import 'color_suggestion.dart';
import 'reference_colors.dart';

class ColorRecommendationService {
  const ColorRecommendationService();

  /// [inputs]의 각 (카테고리, 색상) 쌍을 기준으로 전체 카테고리 색상 추천을 생성한다.
  ///
  /// 알고리즘 개요:
  ///   1. 각 입력 색상 → [mapToReference]로 기준 색상 매핑.
  ///   2. 단일 입력: 해당 기준 색상의 매칭 리스트 사용.
  ///      다중 입력: 교집합 색상 우선, 나머지는 첫 번째 입력으로 보완.
  ///   3. 입력 카테고리를 제외한 대상 카테고리에 오프셋 균등 분배.
  ///   4. [pointCategory]는 채도 높은 유채색 우선 (포인트 로직).
  ColorRecommendation recommend(
    List<(ClothingCategory, Color)> inputs, {
    ClothingCategory pointCategory = ClothingCategory.socks,
  }) {
    final sortedLists = inputs.map((e) {
      final ref = mapToReference(e.$2);
      final raw = colorMatchingRules[ref] ?? const [];
      return List<ColorMatch>.from(raw)
        ..sort((a, b) => a.grade.index.compareTo(b.grade.index));
    }).toList();

    final merged = _mergeMatchLists(sortedLists);

    final inputCats = {for (final e in inputs) e.$1};
    final targetCats = ClothingCategory.values
        .where((c) => !inputCats.contains(c))
        .toList();

    // 추천 대상이 없으면 빈 결과 반환 (UI에서 6개 이하로 막지만 방어적 처리)
    if (targetCats.isEmpty) {
      return ColorRecommendation(
        baseColors: [for (final e in inputs) e.$2],
        baseCategories: [for (final e in inputs) e.$1],
        pointCategory: pointCategory,
        suggestions: const {},
      );
    }

    // pointCategory가 대상 밖이면 socks 또는 첫 번째 대상으로 대체
    final effectivePoint = targetCats.contains(pointCategory)
        ? pointCategory
        : (targetCats.contains(ClothingCategory.socks)
            ? ClothingCategory.socks
            : targetCats.first);

    final offsets = _buildOffsetMap(merged.length, targetCats, effectivePoint);

    return ColorRecommendation(
      baseColors: [for (final e in inputs) e.$2],
      baseCategories: [for (final e in inputs) e.$1],
      pointCategory: effectivePoint,
      suggestions: {
        for (final cat in targetCats)
          cat: cat == effectivePoint
              ? _buildPointSuggestions(merged)
              : _buildRotatedSuggestions(merged, offsets[cat]!),
      },
    );
  }

  // ─── 매칭 리스트 병합 ─────────────────────────────────────────────────────────

  /// 여러 입력의 매칭 리스트를 교집합 우선으로 병합.
  /// 공통 색상은 등급이 가장 좋은 값을 사용, 나머지는 첫 번째 리스트로 보완.
  static List<ColorMatch> _mergeMatchLists(List<List<ColorMatch>> lists) {
    if (lists.isEmpty) return const [];
    if (lists.length == 1) return lists.first;

    final otherMaps = lists
        .skip(1)
        .map((list) => {for (final m in list) m.color: m})
        .toList();

    final common = <ColorMatch>[];
    final rest   = <ColorMatch>[];

    for (final m in lists.first) {
      final allHave = otherMaps.every((map) => map.containsKey(m.color));
      if (allHave) {
        final bestGrade = otherMaps
            .map((map) => map[m.color]!.grade.index)
            .fold(m.grade.index, min);
        common.add(ColorMatch(m.color, MatchGrade.values[bestGrade]));
      } else {
        rest.add(m);
      }
    }

    // lists.first는 이미 grade 순 정렬이므로 재정렬 불필요
    return [...common, ...rest];
  }

  // ─── 분배 로직 ───────────────────────────────────────────────────────────────

  /// [sorted] 리스트에서 [offset] 위치부터 3개를 순환 슬라이싱.
  List<ColorSuggestion> _buildRotatedSuggestions(
      List<ColorMatch> sorted, int offset) {
    final n = sorted.length;
    if (n == 0) return const [];
    return [
      for (var j = 0; j < 3; j++)
        _toSuggestion(sorted[(offset + j) % n]),
    ];
  }

  /// 포인트 카테고리 전용: 채도 높은 유채색 3종 우선 선택.
  /// 유채색이 부족하면 뉴트럴로 보충.
  List<ColorSuggestion> _buildPointSuggestions(List<ColorMatch> sorted) {
    final chromatic = sorted.where(_isChromatic).toList()
      ..sort((a, b) {
        final aS = HSVColor.fromColor(a.color.color).saturation;
        final bS = HSVColor.fromColor(b.color.color).saturation;
        return bS.compareTo(aS);
      });

    final picks = <ColorMatch>[...chromatic];
    for (final m in sorted) {
      if (picks.length >= 3) break;
      if (!picks.contains(m)) picks.add(m);
    }

    return picks.take(3).map(_toSuggestion).toList();
  }

  static bool _isChromatic(ColorMatch m) =>
      m.color != ReferenceColor.white &&
      m.color != ReferenceColor.black &&
      m.color != ReferenceColor.gray &&
      m.color != ReferenceColor.beige;

  // ─── 카테고리 오프셋 ─────────────────────────────────────────────────────────

  /// 대상 카테고리([targetCats])를 [n]개 슬롯에 균등 분배.
  /// [pointCategory]는 rotate 대상에서 제외 (포인트 로직 별도 처리).
  /// n < rotateCats.length이면 비율 매핑 후 충돌 시 다음 빈 슬롯으로 이동.
  static Map<ClothingCategory, int> _buildOffsetMap(
      int n, List<ClothingCategory> targetCats, ClothingCategory pointCategory) {
    final rotateCats = targetCats.where((c) => c != pointCategory).toList();
    if (n == 0) return {for (final c in rotateCats) c: 0};

    final result = <ClothingCategory, int>{};
    final used   = <int>{};

    for (var i = 0; i < rotateCats.length; i++) {
      var idx = (i * n / rotateCats.length).floor();
      while (used.contains(idx) && used.length < n) {
        idx = (idx + 1) % n;
      }
      result[rotateCats[i]] = idx;
      used.add(idx);
    }

    return result;
  }

  // ─── ColorSuggestion 생성 ───────────────────────────────────────────────────

  static ColorSuggestion _toSuggestion(ColorMatch match) => ColorSuggestion(
    color: match.color.color,
    harmonyType: _harmonyTypeForGrade(match.grade),
    description: _descriptionFor(match.color, match.grade),
    confidence: _confidenceForGrade(match.grade),
  );

  static ColorHarmonyType _harmonyTypeForGrade(MatchGrade g) => switch (g) {
    MatchGrade.excellent => ColorHarmonyType.analogous,
    MatchGrade.good      => ColorHarmonyType.complementary,
    MatchGrade.okay      => ColorHarmonyType.triad,
  };

  static double _confidenceForGrade(MatchGrade g) => switch (g) {
    MatchGrade.excellent => 0.92,
    MatchGrade.good      => 0.80,
    MatchGrade.okay      => 0.65,
  };

  /// "색상명 — 등급 설명" 형식.
  /// RecommendationScreen._SuggestionCard의 ' — ' split 규칙과 일치해야 함.
  static String _descriptionFor(ReferenceColor ref, MatchGrade grade) {
    final gradeLabel = switch (grade) {
      MatchGrade.excellent => 'A+ 조합',
      MatchGrade.good      => '잘 어울리는 조합',
      MatchGrade.okay      => '무난한 조합',
    };
    return '${ref.label} — $gradeLabel';
  }
}
