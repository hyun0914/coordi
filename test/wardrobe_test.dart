import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';
import 'package:coordi/features/wardrobe/domain/wardrobe.dart';
import 'package:coordi/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:coordi/features/wardrobe/providers/wardrobe_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('모든 기준 색상은 자기 자신으로 매핑된다 (보유 표시의 전제)', () {
    for (final ref in ReferenceColor.values) {
      expect(mapToReference(ref.color), ref);
    }
  });

  group('WardrobeNotifier', () {
    test('toggle로 추가/제거되고 새 컨테이너(앱 재시작)에서도 복원된다', () async {
      final first = ProviderContainer();
      addTearDown(first.dispose);
      final notifier = first.read(wardrobeProvider.notifier);

      await notifier.toggle(ClothingCategory.top, ReferenceColor.navy);
      await notifier.toggle(ClothingCategory.top, ReferenceColor.white);
      await notifier.toggle(ClothingCategory.shoes, ReferenceColor.black);
      await notifier.toggle(ClothingCategory.top, ReferenceColor.navy);

      final second = ProviderContainer();
      addTearDown(second.dispose);
      final wardrobe = await second.read(wardrobeProvider.future);

      expect(wardrobe[ClothingCategory.top], {ReferenceColor.white});
      expect(wardrobe[ClothingCategory.shoes], {ReferenceColor.black});
    });

    test('깨진 데이터는 빈 옷장으로 시작한다', () async {
      SharedPreferences.setMockInitialValues({'wardrobe_v1': 'not json'});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(wardrobeProvider.future), isEmpty);
    });

    test('알 수 없는 색상 이름은 건너뛴다', () async {
      SharedPreferences.setMockInitialValues({
        'wardrobe_v1': '{"top":["navy","mustard"],"unknown":["white"]}',
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        await container.read(wardrobeProvider.future),
        {ClothingCategory.top: {ReferenceColor.navy}},
      );
    });
  });

  group('randomWardrobeInputs', () {
    test('보유한 메인 카테고리만, 보유한 색상 안에서 고른다', () {
      final Wardrobe wardrobe = {
        ClothingCategory.top:    {ReferenceColor.navy, ReferenceColor.white},
        ClothingCategory.bottom: {},
        ClothingCategory.shoes:  {ReferenceColor.black},
      };

      for (var seed = 0; seed < 20; seed++) {
        final inputs = randomWardrobeInputs(wardrobe, Random(seed));
        expect(inputs.length, 1);
        expect(inputs.single.$1, ClothingCategory.top);
        expect(
          [ReferenceColor.navy.color, ReferenceColor.white.color],
          contains(inputs.single.$2),
        );
      }
    });

    test('빈 옷장이면 입력이 없다', () {
      expect(randomWardrobeInputs({}, Random(0)), isEmpty);
    });
  });

  testWidgets('옷장 화면: 색상을 선택하면 등록되고 추천 버튼이 활성화된다', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WardrobeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('상의·하의·아우터 색상을 먼저 등록해주세요'), findsOneWidget);

    await tester.tap(find.text('상의'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('네이비'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);

    // 시트 닫기
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('내 옷장 색으로 코디 추천'));
    await tester.pumpAndSettle();
    expect(find.byType(RecommendationScreen), findsOneWidget);
    expect(find.text('상의 선택 색상'), findsOneWidget);
  });

  testWidgets('추천 결과: 옷장에 있는 색상에만 보유 표시가 붙는다', (tester) async {
    final recommendation = const ColorRecommendationService().recommend(
      [(ClothingCategory.top, ReferenceColor.navy.color)],
    );
    final shoes = recommendation.suggestions[ClothingCategory.shoes]!;
    final ownedRef = mapToReference(shoes.first.color);
    final ownedCount = recommendation.suggestions[ClothingCategory.shoes]!
        .where((s) => mapToReference(s.color) == ownedRef)
        .length;

    SharedPreferences.setMockInitialValues({
      'wardrobe_v1': '{"shoes":["${ownedRef.name}"]}',
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: RecommendationScreen(recommendation: recommendation),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('보유', skipOffstage: false), findsNWidgets(ownedCount));
  });

  testWidgets('좁은 화면에서도 옷장 화면과 색상 시트가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      'wardrobe_v1': '{"top":${[for (final r in ReferenceColor.values) '"${r.name}"']}}',
    });
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WardrobeScreen())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('상의'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
