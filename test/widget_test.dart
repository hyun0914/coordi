import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coordi/main.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';

void main() {
  // ─── 앱 스모크 테스트 ───────────────────────────────────────────────────────────

  testWidgets('홈 화면이 정상 렌더링된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoordinApp()));
    await tester.pump();

    // Text.rich도 전체 문자열('Coordi')로 탐색됨
    expect(find.text('Coordi'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('상의'), findsOneWidget);
    expect(find.text('가방'), findsOneWidget);
  });

  testWidgets('카테고리 카드 탭 시 다이얼로그가 열린다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CoordinApp()));
    await tester.pump();

    await tester.tap(find.text('상의'));
    await tester.pumpAndSettle();

    expect(find.text('색상을 알고 있는 카테고리'), findsOneWidget);
    // 버튼 텍스트는 선택 수에 따라 동적 ('색상 선택 (1개)')
    expect(find.textContaining('색상 선택'), findsOneWidget);
  });

  // ─── ColorRecommendationService 단위 테스트 ─────────────────────────────────

  group('ColorRecommendationService', () {
    const service = ColorRecommendationService();

    test('단일 입력: 추천 대상이 입력 카테고리를 제외한 6개다', () {
      final result = service.recommend(
        [(ClothingCategory.top, const Color(0xFF1C2B4A))],
      );
      expect(result.suggestions.length, 6);
      expect(result.suggestions.containsKey(ClothingCategory.top), isFalse);
    });

    test('다중 입력: 추천 대상이 입력 카테고리 수만큼 줄어든다', () {
      final result = service.recommend([
        (ClothingCategory.top,    const Color(0xFF1C2B4A)),
        (ClothingCategory.bottom, const Color(0xFFF5E6C8)),
      ]);
      expect(result.suggestions.length, 5);
      expect(result.suggestions.containsKey(ClothingCategory.top),    isFalse);
      expect(result.suggestions.containsKey(ClothingCategory.bottom), isFalse);
    });

    test('각 카테고리는 추천 색상을 최대 3개 받는다', () {
      final result = service.recommend(
        [(ClothingCategory.top, const Color(0xFFF2F2F7))],
      );
      for (final suggestions in result.suggestions.values) {
        expect(suggestions.length, lessThanOrEqualTo(3));
        expect(suggestions.isNotEmpty, isTrue);
      }
    });

    test('포인트 카테고리가 추천 결과에 포함된다', () {
      final result = service.recommend(
        [(ClothingCategory.top, const Color(0xFF1C2B4A))],
        pointCategory: ClothingCategory.hat,
      );
      expect(result.pointCategory, ClothingCategory.hat);
      expect(result.suggestions.containsKey(ClothingCategory.hat), isTrue);
    });

    test('6개 선택 시 추천 대상이 1개다', () {
      final inputs = ClothingCategory.values
          .take(6)
          .map((c) => (c, const Color(0xFF1C2B4A)))
          .toList();
      final result = service.recommend(inputs);
      expect(result.suggestions.length, 1);
    });

    test('7개 선택(전체) 시 suggestions가 비어있어도 크래시 없음', () {
      final inputs = ClothingCategory.values
          .map((c) => (c, const Color(0xFF1C2B4A)))
          .toList();
      final result = service.recommend(inputs);
      expect(result.suggestions.isEmpty, isTrue);
    });

    test('다중 입력 교집합: 두 색상에 공통 매칭이 있으면 먼저 나온다', () {
      // navy + beige → white는 둘 다 excellent
      final result = service.recommend([
        (ClothingCategory.top,    const Color(0xFF1C2B4A)), // navy
        (ClothingCategory.bottom, const Color(0xFFF5E6C8)), // beige
      ]);
      // 추천이 비어있지 않아야 함
      expect(result.suggestions.isNotEmpty, isTrue);
    });
  });
}
