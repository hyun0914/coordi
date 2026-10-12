import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'reference_colors.dart';

/// 미리 정해둔 기준 색 조합. 색상 피커를 거치지 않고 바로 추천을 시작할 때 쓴다.
class ColorPreset {
  const ColorPreset({
    required this.name,
    required this.description,
    required this.colors,
  });

  final String name;
  final String description;

  /// 기준색 입력 대상(상의/하의/아우터) 카테고리별 색상.
  final Map<ClothingCategory, ReferenceColor> colors;

  /// [ColorRecommendationService.recommend]에 넘길 입력 (enum 선언 순서).
  List<(ClothingCategory, Color)> get inputs => [
        for (final category in ClothingCategory.values)
          if (colors[category] case final ref?) (category, ref.color),
      ];
}

const List<ColorPreset> colorPresets = [
  ColorPreset(
    name: '모노톤',
    description: '화이트와 블랙의 깔끔한 대비',
    colors: {
      ClothingCategory.top:    ReferenceColor.white,
      ClothingCategory.bottom: ReferenceColor.black,
    },
  ),
  ColorPreset(
    name: '어스톤',
    description: '베이지·브라운·카키의 차분한 자연색',
    colors: {
      ClothingCategory.top:    ReferenceColor.beige,
      ClothingCategory.bottom: ReferenceColor.brown,
      ClothingCategory.outer:  ReferenceColor.khaki,
    },
  ),
  ColorPreset(
    name: '네이비 × 옐로우',
    description: '짙은 네이비에 밝은 포인트',
    colors: {
      ClothingCategory.top:    ReferenceColor.yellow,
      ClothingCategory.bottom: ReferenceColor.navy,
    },
  ),
  ColorPreset(
    name: '소프트 블루',
    description: '라이트블루와 베이지의 부드러운 조합',
    colors: {
      ClothingCategory.top:    ReferenceColor.lightBlue,
      ClothingCategory.bottom: ReferenceColor.beige,
    },
  ),
  ColorPreset(
    name: '데님 캐주얼',
    description: '화이트 상의에 데님 하의',
    colors: {
      ClothingCategory.top:    ReferenceColor.white,
      ClothingCategory.bottom: ReferenceColor.denimBlue,
    },
  ),
  ColorPreset(
    name: '버건디 클래식',
    description: '버건디에 베이지를 더한 가을 무드',
    colors: {
      ClothingCategory.top:    ReferenceColor.burgundy,
      ClothingCategory.bottom: ReferenceColor.beige,
    },
  ),
  ColorPreset(
    name: '카키 × 네이비',
    description: '차분하고 단정한 워크웨어 톤',
    colors: {
      ClothingCategory.top:    ReferenceColor.khaki,
      ClothingCategory.bottom: ReferenceColor.navy,
    },
  ),
  ColorPreset(
    name: '핑크 × 그레이',
    description: '부드러운 핑크를 그레이로 눌러준 조합',
    colors: {
      ClothingCategory.top:    ReferenceColor.pink,
      ClothingCategory.bottom: ReferenceColor.gray,
    },
  ),
];
