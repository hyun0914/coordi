import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/favorites/providers/favorites_provider.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';

void main() {
  final recommendation = const ColorRecommendationService().recommend([
    (ClothingCategory.top,    const Color(0xFF1C2B4A)),
    (ClothingCategory.bottom, const Color(0xFFF5E6C8)),
  ]);

  test('ColorRecommendation: JSON 왕복 후 내용이 동일하다', () {
    final restored = ColorRecommendation.fromJson(
      jsonDecode(jsonEncode(recommendation.toJson())) as Map<String, dynamic>,
    );

    expect(restored.baseColors, recommendation.baseColors);
    expect(restored.baseCategories, recommendation.baseCategories);
    expect(restored.pointCategory, recommendation.pointCategory);
    expect(
      restored.suggestions.keys.toList(),
      recommendation.suggestions.keys.toList(),
    );
    for (final cat in recommendation.suggestions.keys) {
      final before = recommendation.suggestions[cat]!;
      final after  = restored.suggestions[cat]!;
      expect(after.length, before.length);
      for (var i = 0; i < before.length; i++) {
        expect(after[i].color, before[i].color);
        expect(after[i].harmonyType, before[i].harmonyType);
        expect(after[i].description, before[i].description);
        expect(after[i].confidence, before[i].confidence);
      }
    }
  });

  group('FavoritesNotifier', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('저장한 항목은 새 컨테이너(앱 재시작)에서도 복원된다', () async {
      final first = ProviderContainer();
      addTearDown(first.dispose);
      final id = await first.read(favoritesProvider.notifier).add(recommendation);

      final second = ProviderContainer();
      addTearDown(second.dispose);
      final items = await second.read(favoritesProvider.future);

      expect(items.single.id, id);
      expect(items.single.recommendation.baseColors, recommendation.baseColors);
    });

    test('삭제 후 restore하면 원래 순서로 돌아온다', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(favoritesProvider.notifier);

      final older = await notifier.add(recommendation);
      final newer = await notifier.add(recommendation);
      final removed = (await container.read(favoritesProvider.future)).last;

      await notifier.remove(older);
      expect(
        container.read(favoritesProvider).value!.map((e) => e.id),
        [newer],
      );

      await notifier.restore(removed);
      expect(
        container.read(favoritesProvider).value!.map((e) => e.id),
        [newer, older],
      );
    });

    test('복원할 수 없는 항목은 건너뛴다', () async {
      SharedPreferences.setMockInitialValues({
        'favorites_v1': ['{"broken":true}', 'not json'],
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(favoritesProvider.future), isEmpty);
    });
  });
}
