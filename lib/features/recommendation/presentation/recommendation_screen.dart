import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation.dart';
import 'package:coordi/features/recommendation/domain/color_suggestion.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key, required this.recommendation});

  final ColorRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final others = recommendation.suggestions.keys.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: cs.surfaceTint,
        title: Text(
          '추천 결과',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _BaseColorHeader(recommendation: recommendation),
                  ),
                ),
                if (others.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                      child: Text(
                        '나머지 카테고리 추천',
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                    sliver: SliverList.separated(
                      itemCount: others.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 20),
                      itemBuilder: (context, i) {
                        final cat = others[i];
                        return _CategorySection(
                          category: cat,
                          suggestions: recommendation.suggestions[cat]!,
                          isPoint: cat == recommendation.pointCategory,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 베이스 색상 헤더 ────────────────────────────────────────────────────────────

class _BaseColorHeader extends StatelessWidget {
  const _BaseColorHeader({required this.recommendation});

  final ColorRecommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final count  = recommendation.baseColors.length;
    final isSingle = count == 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Text(
            isSingle ? '선택한 기준 색상' : '선택한 기준 색상 ($count개)',
            style: tt.labelMedium?.copyWith(
              color: cs.primary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),

          // 색상 표시: 1개는 Row 레이아웃, 2개 이상은 가로 나열
          if (isSingle)
            _SingleInputRow(
              category: recommendation.baseCategories[0],
              color: recommendation.baseColors[0],
            )
          else
            Row(
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) ...[
                    const SizedBox(width: 8),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 4,
                      endIndent: 4,
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _MultiInputCard(
                      category: recommendation.baseCategories[i],
                      color: recommendation.baseColors[i],
                    ),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 14),

          // 설명 텍스트 (단수/복수 대응)
          Text(
            isSingle
                ? '이 색상을 기준으로 나머지 카테고리를 어울리는 색상으로 추천해드립니다.'
                : '이 색상들을 기준으로 공통으로 어울리는 색상을 추천해드립니다.',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 단일 입력: 큰 스와치(72) + 카테고리/HEX 정보를 Row로 배치 (기존 단일 입력 레이아웃 유지).
class _SingleInputRow extends StatelessWidget {
  const _SingleInputRow({required this.category, required this.color});

  final ClothingCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isLight = color.computeLuminance() > 0.85;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isLight
                ? Border.all(color: cs.outlineVariant, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${category.label} 선택 색상',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _hexFromColor(color),
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 다중 입력: 작은 스와치(48) + 카테고리명 + HEX를 세로로 쌓아 가로 나열용 카드.
class _MultiInputCard extends StatelessWidget {
  const _MultiInputCard({required this.category, required this.color});

  final ClothingCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isLight = color.computeLuminance() > 0.85;

    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isLight
                ? Border.all(color: cs.outlineVariant, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.42),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _hexFromColor(color),
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─── 빈 상태 (suggestions == {}) ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.layers_clear_outlined,
              size: 56,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '추천할 카테고리가 없습니다',
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '카테고리를 줄여서 다시 시도해주세요.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 카테고리 섹션 ───────────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.suggestions,
    required this.isPoint,
  });

  final ClothingCategory category;
  final List<ColorSuggestion> suggestions;
  final bool isPoint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 카테고리 라벨 칩
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.label,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // 포인트 배지
            if (isPoint) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 11,
                      color: cs.onTertiaryContainer,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '포인트',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < suggestions.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _SuggestionCard(suggestion: suggestions[i])),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── 추천 카드 ───────────────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final ColorSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final pct = (suggestion.confidence * 100).round();

    final confColor = pct >= 88
        ? const Color(0xFF2E7D32)
        : pct >= 80
            ? cs.primary
            : cs.onSurface.withValues(alpha: 0.4);

    final parts     = suggestion.description.split(' — ');
    final colorName = parts.first;
    final detail    = parts.length > 1 ? parts[1] : '';

    final isLight = suggestion.color.computeLuminance() > 0.85;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: suggestion.color,
              shape: BoxShape.circle,
              border: isLight
                  ? Border.all(color: cs.outlineVariant, width: 1.5)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: suggestion.color.withValues(alpha: 0.38),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hexFromColor(suggestion.color),
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            colorName,
            style: tt.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.80),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.42),
                height: 1.3,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: confColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$pct%',
              style: tt.labelSmall?.copyWith(
                color: confColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 유틸 ────────────────────────────────────────────────────────────────────────

String _hexFromColor(Color c) {
  final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}
