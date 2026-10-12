import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/home/presentation/home_screen.dart';
import 'package:coordi/features/recommendation/domain/color_presets.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  const service = ColorRecommendationService();

  for (final preset in colorPresets) {
    group('프리셋 "${preset.name}"', () {
      test('기준색 입력 대상 카테고리만 사용한다', () {
        expect(preset.colors, isNotEmpty);
        expect(preset.colors.keys.every((c) => c.isMain), isTrue);
      });

      test('입력 색상이 의도한 기준 색상으로 매핑된다', () {
        for (final (category, color) in preset.inputs) {
          expect(mapToReference(color), preset.colors[category]);
        }
      });

      test('나머지 모든 카테고리에 추천 색상이 나온다', () {
        final result = service.recommend(preset.inputs);
        final expected = ClothingCategory.values
            .where((c) => !preset.colors.containsKey(c))
            .toSet();

        expect(result.suggestions.keys.toSet(), expected);
        for (final suggestions in result.suggestions.values) {
          expect(suggestions, isNotEmpty);
        }
      });
    });
  }

  test('프리셋 이름은 중복되지 않는다', () {
    final names = colorPresets.map((p) => p.name).toSet();
    expect(names.length, colorPresets.length);
  });

  testWidgets('프리셋 카드를 누르면 추천 결과 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    final card = find.text(colorPresets.first.name);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(RecommendationScreen), findsOneWidget);
    expect(find.text('선택한 기준 색상 (2개)'), findsOneWidget);
  });

  testWidgets('좁은 화면에서도 프리셋 카드가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
