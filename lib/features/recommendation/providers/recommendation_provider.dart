import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/domain/season.dart';

/// 서비스 싱글턴. const 생성자라 불필요한 재생성이 없다.
final colorRecommendationServiceProvider =
    Provider<ColorRecommendationService>((ref) {
  return const ColorRecommendationService();
});

/// 홈에서 고른 계절 톤. null = 전체(계절 구분 없음).
/// 앱을 새로 열면 전체로 돌아간다.
final seasonProvider = StateProvider<Season?>((ref) => null);
