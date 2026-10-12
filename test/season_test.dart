import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/home/presentation/home_screen.dart';
import 'package:coordi/features/recommendation/domain/color_presets.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';
import 'package:coordi/features/recommendation/domain/season.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';

void main() {
  const service = ColorRecommendationService();

  Set<ReferenceColor> suggestedRefs(ColorRecommendation r) => {
        for (final list in r.suggestions.values)
          for (final s in list) mapToReference(s.color),
      };

  test('season을 주지 않으면 기존 추천과 동일하다', () {
    final inputs = [(ClothingCategory.top, ReferenceColor.navy.color)];
    final a = service.recommend(inputs);
    final b = service.recommend(inputs, season: null);

    expect(a.season, isNull);
    expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
  });

  test('계절 톤 색상이 충분하면 추천이 그 색상들로만 구성된다', () {
    // 화이트는 나머지 17색과 모두 매칭 → 어느 계절이든 톤 색상이 5개 이상
    for (final season in Season.values) {
      final result = service.recommend(
        [(ClothingCategory.top, ReferenceColor.white.color)],
        season: season,
      );
      expect(result.season, season);
      expect(season.colors.containsAll(suggestedRefs(result)), isTrue,
          reason: season.label);
    }
  });

  test('계절 톤 색상이 부족하면 다른 색상으로 보충하되 톤 색상은 모두 포함한다', () {
    // 카키 매칭: white, beige, navy, cream, denimBlue, brown → 겨울 톤은 white, navy뿐
    final result = service.recommend(
      [(ClothingCategory.top, ReferenceColor.khaki.color)],
      season: Season.winter,
    );
    final refs = suggestedRefs(result);

    expect(refs, containsAll([ReferenceColor.white, ReferenceColor.navy]));
    expect(refs.length, greaterThan(2));
  });

  test('모든 프리셋 × 계절 조합에서 카테고리마다 추천이 나온다', () {
    for (final preset in colorPresets) {
      for (final season in Season.values) {
        final result = service.recommend(preset.inputs, season: season);
        for (final list in result.suggestions.values) {
          expect(list, isNotEmpty, reason: '${preset.name} / ${season.label}');
        }
      }
    }
  });

  test('JSON: season이 왕복되고, season 키가 없는 기존 데이터도 읽힌다', () {
    final result = service.recommend(
      [(ClothingCategory.top, ReferenceColor.navy.color)],
      season: Season.autumn,
    );
    final json =
        jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>;
    expect(ColorRecommendation.fromJson(json).season, Season.autumn);

    json.remove('season');
    expect(ColorRecommendation.fromJson(json).season, isNull);
  });

  testWidgets('홈에서 고른 계절이 추천 결과에 적용된다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    await tester.tap(find.text('가을'));
    await tester.pumpAndSettle();
    expect(find.textContaining(Season.autumn.description), findsOneWidget);

    final card = find.text(colorPresets.first.name);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(RecommendationScreen), findsOneWidget);
    expect(find.text('가을 톤'), findsOneWidget);
  });
}
