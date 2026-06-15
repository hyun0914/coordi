import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'color_suggestion.dart';

class ColorRecommendation {
  const ColorRecommendation({
    required this.baseColors,
    required this.baseCategories,
    required this.pointCategory,
    required this.suggestions,
  });

  /// 사용자가 선택한 기준 색상들 (입력 순서대로).
  final List<Color> baseColors;

  /// baseColors에 대응하는 입력 카테고리들.
  final List<ClothingCategory> baseCategories;

  /// 포인트 카테고리 (채도 높은 유채색 우선 추천).
  final ClothingCategory pointCategory;

  /// 추천 대상 카테고리별 추천 목록 (baseCategories 제외, 각 최대 3개).
  final Map<ClothingCategory, List<ColorSuggestion>> suggestions;
}
