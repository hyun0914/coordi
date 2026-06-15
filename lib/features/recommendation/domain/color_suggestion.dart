import 'package:flutter/material.dart';
import 'package:coordi/core/constants/color_harmony_type.dart';

class ColorSuggestion {
  const ColorSuggestion({
    required this.color,
    required this.harmonyType,
    required this.description,
    required this.confidence,
  });

  final Color color;
  final ColorHarmonyType harmonyType;
  final String description;

  /// 추천 신뢰도. 0.0 ~ 1.0 범위로, 1.0에 가까울수록 잘 어울리는 조합.
  final double confidence;
}
