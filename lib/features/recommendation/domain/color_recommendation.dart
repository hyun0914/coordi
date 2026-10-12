import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'color_suggestion.dart';
import 'season.dart';

class ColorRecommendation {
  const ColorRecommendation({
    required this.baseColors,
    required this.baseCategories,
    required this.pointCategory,
    required this.suggestions,
    this.season,
  });

  /// 사용자가 선택한 기준 색상들 (입력 순서대로).
  final List<Color> baseColors;

  /// baseColors에 대응하는 입력 카테고리들.
  final List<ClothingCategory> baseCategories;

  /// 포인트 카테고리 (채도 높은 유채색 우선 추천).
  final ClothingCategory pointCategory;

  /// 추천에 적용된 계절 톤. null이면 계절 구분 없이 추천한 결과.
  final Season? season;

  /// 추천 대상 카테고리별 추천 목록 (baseCategories 제외, 각 최대 3개).
  final Map<ClothingCategory, List<ColorSuggestion>> suggestions;

  factory ColorRecommendation.fromJson(Map<String, dynamic> json) {
    ClothingCategory category(Object? name) =>
        ClothingCategory.values.byName(name as String);

    return ColorRecommendation(
      baseColors: [
        for (final c in json['baseColors'] as List) Color(c as int),
      ],
      baseCategories: [
        for (final c in json['baseCategories'] as List) category(c),
      ],
      pointCategory: category(json['pointCategory']),
      // 계절 톤 도입 전에 저장된 항목에는 키가 없다.
      season: switch (json['season']) {
        final String name => Season.values.byName(name),
        _ => null,
      },
      // Map 리터럴은 삽입 순서를 유지하므로 저장 당시 카테고리 순서가 그대로 복원된다.
      suggestions: {
        for (final e in (json['suggestions'] as Map<String, dynamic>).entries)
          category(e.key): [
            for (final s in e.value as List)
              ColorSuggestion.fromJson(s as Map<String, dynamic>),
          ],
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'baseColors': [for (final c in baseColors) c.toARGB32()],
        'baseCategories': [for (final c in baseCategories) c.name],
        'pointCategory': pointCategory.name,
        if (season != null) 'season': season!.name,
        'suggestions': {
          for (final e in suggestions.entries)
            e.key.name: [for (final s in e.value) s.toJson()],
        },
      };
}
