import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/favorites/presentation/favorites_screen.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';

void main() {
  final recommendation = const ColorRecommendationService().recommend(
    [(ClothingCategory.top, const Color(0xFF1C2B4A))],
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('하트를 누르면 저장되고 즐겨찾기 화면에 나타난다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: RecommendationScreen(recommendation: recommendation),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    final context = tester.element(find.byType(RecommendationScreen));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('상의'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump();
    expect(find.text('저장한 코디가 없습니다'), findsOneWidget);
  });

  testWidgets('캡처 영역은 화면 밖 스크롤 영역까지 포함한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: RecommendationScreen(recommendation: recommendation),
        ),
      ),
    );

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(RepaintBoundary),
      ).first,
    );
    final viewport = tester.getSize(find.byType(CustomScrollView));
    expect(boundary.size.height, greaterThan(viewport.height));

    final image = await tester.runAsync(() => boundary.toImage());
    expect(image!.height, boundary.size.height.ceil());
    image.dispose();
  });
}
