import 'package:coordi/features/recommendation/domain/color_recommendation.dart';

/// 즐겨찾기에 저장된 추천 결과 한 건.
class SavedCoordi {
  const SavedCoordi({
    required this.id,
    required this.savedAt,
    required this.recommendation,
  });

  final String id;
  final DateTime savedAt;
  final ColorRecommendation recommendation;

  factory SavedCoordi.fromJson(Map<String, dynamic> json) {
    return SavedCoordi(
      id: json['id'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      recommendation: ColorRecommendation.fromJson(
        json['recommendation'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'recommendation': recommendation.toJson(),
      };
}
