import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coordi/features/favorites/domain/saved_coordi.dart';
import 'package:coordi/features/favorites/providers/favorites_provider.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs        = Theme.of(context).colorScheme;
    final tt        = Theme.of(context).textTheme;
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: cs.surfaceTint,
        title: Text(
          '즐겨찾기',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: favorites.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const _Message(
                icon: Icons.error_outline,
                title: '즐겨찾기를 불러오지 못했습니다',
                detail: '잠시 후 다시 시도해주세요.',
              ),
              data: (items) => items.isEmpty
                  ? const _Message(
                      icon: Icons.favorite_border,
                      title: '저장한 코디가 없습니다',
                      detail: '추천 결과 화면에서 하트를 눌러 저장해보세요.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _FavoriteCard(
                        saved: items[i],
                        onDelete: () => _delete(context, ref, items[i]),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SavedCoordi saved,
  ) async {
    final notifier  = ref.read(favoritesProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    await notifier.remove(saved.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('즐겨찾기에서 삭제했습니다'),
          action: SnackBarAction(
            label: '실행취소',
            onPressed: () => notifier.restore(saved),
          ),
        ),
      );
  }
}

// ─── 즐겨찾기 카드 ───────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.saved, required this.onDelete});

  final SavedCoordi saved;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
    final rec = saved.recommendation;

    return Material(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecommendationScreen(
              recommendation: rec,
              savedId: saved.id,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rec.baseCategories.map((c) => c.label).join(' · '),
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(saved.savedAt),
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: '삭제',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 기준 색상(큰 원) + 카테고리별 1순위 추천 색상(작은 원)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final color in rec.baseColors)
                      _Swatch(color: color, size: 36),
                    if (rec.suggestions.isNotEmpty)
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.35),
                      ),
                    for (final entry in rec.suggestions.entries)
                      if (entry.value.isNotEmpty)
                        Tooltip(
                          message: entry.key.label,
                          child: _Swatch(
                            color: entry.value.first.color,
                            size: 24,
                          ),
                        ),
                  ],
                ),
              ),
            ],
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

// ─── 빈 상태 / 오류 ──────────────────────────────────────────────────────────────

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

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
            Icon(icon, size: 56, color: cs.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              title,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.45),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 유틸 ────────────────────────────────────────────────────────────────────────

String _formatDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}.$mm.$dd';
}
