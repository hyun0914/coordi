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

  // 카테고리 → 아이콘 매핑
  static const Map<ClothingCategory, IconData> _icons = {
    ClothingCategory.top: Icons.checkroom,
    ClothingCategory.bottom: Icons.accessibility,
    ClothingCategory.outer: Icons.dry_cleaning,
    ClothingCategory.shoes: Icons.directions_walk,
    ClothingCategory.socks: Icons.style,
    ClothingCategory.hat: Icons.face,
    ClothingCategory.bag: Icons.shopping_bag,
  };

  // 카테고리별 독립적인 포인트 컬러 — 카드를 시각적으로 구분
  static const Map<ClothingCategory, Color> _accents = {
    ClothingCategory.top: Color(0xFF5C6BC0),
    ClothingCategory.bottom: Color(0xFF26A69A),
    ClothingCategory.outer: Color(0xFFEF5350),
    ClothingCategory.shoes: Color(0xFFAB47BC),
    ClothingCategory.socks: Color(0xFFFF7043),
    ClothingCategory.hat: Color(0xFF66BB6A),
    ClothingCategory.bag: Color(0xFFFFA726),
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[category]!;
    final accent = _accents[category]!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 컨테이너 — 원형 배경에 포인트 컬러 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                category.label,
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
