import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';
import 'package:coordi/features/recommendation/providers/recommendation_provider.dart';
import 'package:coordi/features/wardrobe/domain/wardrobe.dart';
import 'package:coordi/features/wardrobe/providers/wardrobe_provider.dart';

class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs       = Theme.of(context).colorScheme;
    final tt       = Theme.of(context).textTheme;
    final wardrobe = ref.watch(wardrobeProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: cs.surfaceTint,
        title: Text(
          '내 옷장',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: wardrobe.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  '옷장을 불러오지 못했습니다',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              data: (data) => _WardrobeBody(wardrobe: data),
            ),
          ),
        ),
      ),
    );
  }
}

class _WardrobeBody extends ConsumerWidget {
  const _WardrobeBody({required this.wardrobe});

  final Wardrobe wardrobe;

  /// 보유한 상의/하의/아우터 색상에서 무작위로 골라 추천 결과 화면으로 이동.
  void _recommend(BuildContext context, WidgetRef ref) {
    final recommendation = const ColorRecommendationService().recommend(
      randomWardrobeInputs(wardrobe, Random()),
      season: ref.read(seasonProvider),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(recommendation: recommendation),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final canRecommend = ClothingCategory.mainCategories
        .any((c) => wardrobe[c]?.isNotEmpty ?? false);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text(
                '가지고 있는 옷의 색상을 카테고리별로 등록해두면\n추천 결과에서 보유한 색상을 표시해드립니다.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              for (final category in ClothingCategory.values) ...[
                _CategorySection(
                  category: category,
                  colors: wardrobe[category] ?? const {},
                ),
                if (category != ClothingCategory.values.last)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canRecommend ? () => _recommend(context, ref) : null,
              icon: const Icon(Icons.shuffle, size: 18),
              label: Text(
                canRecommend
                    ? '내 옷장 색으로 코디 추천'
                    : '상의·하의·아우터 색상을 먼저 등록해주세요',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 카테고리 섹션 ───────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.colors});

  final ClothingCategory category;
  final Set<ReferenceColor> colors;

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => _ColorSelectSheet(category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _edit(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  category.label,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: colors.isEmpty
                    ? Text(
                        '등록된 색상 없음',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final ref in colors)
                            Tooltip(
                              message: ref.label,
                              child: _Swatch(color: ref.color, size: 26),
                            ),
                        ],
                      ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 색상 선택 시트 ──────────────────────────────────────────────────────────────

class _ColorSelectSheet extends ConsumerWidget {
  const _ColorSelectSheet({required this.category});

  final ClothingCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final owned =
        ref.watch(wardrobeProvider).valueOrNull?[category] ?? const {};

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${category.label} 색상',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '가지고 있는 색상을 모두 선택하세요.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              runSpacing: 8,
              children: [
                for (final color in ReferenceColor.values)
                  _ColorOption(
                    color: color,
                    selected: owned.contains(color),
                    onTap: () => ref
                        .read(wardrobeProvider.notifier)
                        .toggle(category, color),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final ReferenceColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // 스와치 위 체크 표시는 배경 밝기에 따라 대비되는 색으로.
    final checkColor =
        color.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Semantics(
      button: true,
      selected: selected,
      label: color.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    _Swatch(color: color.color, size: 38),
                    if (selected) Icon(Icons.check, size: 20, color: checkColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  color.label,
                  style: tt.labelSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: cs.onSurface.withValues(alpha: selected ? 0.9 : 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final isLight = color.computeLuminance() > 0.85;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isLight
            ? Border.all(color: cs.outlineVariant, width: 1.5)
            : null,
      ),
    );
  }
}
