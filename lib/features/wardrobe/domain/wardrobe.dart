import 'dart:math';
import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';

/// 카테고리별로 보유한 옷의 색상. 사진이나 개별 아이템 없이 색상만 기록한다.
typedef Wardrobe = Map<ClothingCategory, Set<ReferenceColor>>;

/// 보유한 상의/하의/아우터 중 카테고리마다 하나씩 무작위로 골라 추천 입력을 만든다.
/// 해당 카테고리에 보유 색상이 없으면 그 카테고리는 입력에서 빠진다.
List<(ClothingCategory, Color)> randomWardrobeInputs(
  Wardrobe wardrobe,
  Random random,
) {
  return [
    for (final category in ClothingCategory.mainCategories)
      if (wardrobe[category] case final colors? when colors.isNotEmpty)
        (category, colors.elementAt(random.nextInt(colors.length)).color),
  ];
}
