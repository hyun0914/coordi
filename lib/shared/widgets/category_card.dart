import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final ClothingCategory category;
  final VoidCallback onTap;

  static const Map<ClothingCategory, IconData> _icons = {
    ClothingCategory.top:    Icons.checkroom,
    ClothingCategory.bottom: Icons.accessibility,
    ClothingCategory.outer:  Icons.dry_cleaning,
    ClothingCategory.shoes:  Icons.directions_walk,
    ClothingCategory.socks:  Icons.style,
    ClothingCategory.hat:    Icons.face,
    ClothingCategory.bag:    Icons.shopping_bag,
  };

  static const Map<ClothingCategory, Color> _accents = {
    ClothingCategory.top:    Color(0xFF5C6BC0),
    ClothingCategory.bottom: Color(0xFF26A69A),
    ClothingCategory.outer:  Color(0xFFEF5350),
    ClothingCategory.shoes:  Color(0xFFAB47BC),
    ClothingCategory.socks:  Color(0xFFFF7043),
    ClothingCategory.hat:    Color(0xFF66BB6A),
    ClothingCategory.bag:    Color(0xFFFFA726),
  };

  static const Map<ClothingCategory, String> _subtitles = {
    ClothingCategory.top:    '셔츠, 니트, 티셔츠 등',
    ClothingCategory.bottom: '바지, 스커트, 반바지 등',
    ClothingCategory.outer:  '코트, 자켓, 패딩 등',
  };

  @override
  Widget build(BuildContext context) {
    final icon    = _icons[category]!;
    final accent  = _accents[category]!;
    final subtitle = _subtitles[category];
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
