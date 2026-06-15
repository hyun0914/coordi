import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';

/// 서비스 싱글턴. const 생성자라 불필요한 재생성이 없다.
final colorRecommendationServiceProvider =
    Provider<ColorRecommendationService>((ref) {
  return const ColorRecommendationService();
});
