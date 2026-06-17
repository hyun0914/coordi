import 'package:flutter/material.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/color_picker/presentation/color_picker_screen.dart';
import 'package:coordi/shared/widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(),
                  const SizedBox(height: 32),
                  _CategoryList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: cs.surfaceTint,
      title: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
          children: [
            TextSpan(text: 'Coo', style: TextStyle(color: cs.onSurface)),
            TextSpan(text: 'rdi', style: TextStyle(color: cs.primary)),
          ],
        ),
      ),
    );
  }
}

// ─── 헤더 섹션 ─────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '색상 코디 추천',
            style: tt.labelSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '어떤 옷의 색상을\n알고 있나요?',
          style: tt.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.25,
            letterSpacing: -0.5,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '상의·하의·아우터 중 색상을 알고 있는 항목을 선택하면\n신발·양말·모자·가방 색상 조합을 추천해드립니다.',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─── 카테고리 리스트 ────────────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final category in ClothingCategory.mainCategories) ...[
          CategoryCard(
            category: category,
            onTap: () => _onTap(context, category),
          ),
          if (category != ClothingCategory.mainCategories.last)
            const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _onTap(BuildContext context, ClothingCategory category) {
    showDialog(
      context: context,
      builder: (_) => _CategoryMultiSelectDialog(initialCategory: category),
    );
  }
}

// ─── 카테고리 멀티셀렉트 다이얼로그 ─────────────────────────────────────────────

class _CategoryMultiSelectDialog extends StatefulWidget {
  const _CategoryMultiSelectDialog({required this.initialCategory});

  final ClothingCategory initialCategory;

  @override
  State<_CategoryMultiSelectDialog> createState() =>
      _CategoryMultiSelectDialogState();
}

class _CategoryMultiSelectDialogState
    extends State<_CategoryMultiSelectDialog> {
  // 상의/하의/아우터 3개 중 최대 3개 선택 가능 (신발·양말·모자·가방은 항상 추천 대상)
  static final _maxSelect = ClothingCategory.mainCategories.length;

  late final Set<ClothingCategory> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {widget.initialCategory};
  }

  void _toggle(ClothingCategory cat) {
    setState(() {
      if (_selected.contains(cat)) {
        _selected.remove(cat);
      } else if (_selected.length < _maxSelect) {
        _selected.add(cat);
      }
    });
  }

  void _onConfirm() {
    final cats = ClothingCategory.values
        .where(_selected.contains)
        .toList(); // enum 선언 순서 유지
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ColorPickerScreen(categories: cats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '색상을 알고 있는 카테고리',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            _selected.length >= _maxSelect
                ? '모두 선택됨'
                : '여러 개 선택 가능',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ClothingCategory.mainCategories.map((cat) {
          final isSelected = _selected.contains(cat);
          final maxReached = _selected.length >= _maxSelect;
          return FilterChip(
            label: Text(cat.label),
            selected: isSelected,
            onSelected: (!isSelected && maxReached) ? null : (_) => _toggle(cat),
            selectedColor: cs.primaryContainer,
            checkmarkColor: cs.onPrimaryContainer,
            labelStyle: tt.labelMedium?.copyWith(
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? cs.onPrimaryContainer
                  : cs.onSurface.withValues(alpha: 0.75),
            ),
            side: BorderSide(
              color: isSelected
                  ? cs.primary.withValues(alpha: 0.5)
                  : cs.outlineVariant,
              width: isSelected ? 1.5 : 0.8,
            ),
          );
        }).toList(),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty ? null : _onConfirm,
          child: Text(
            _selected.isEmpty
                ? '색상 선택'
                : '색상 선택 (${_selected.length}개)',
          ),
        ),
      ],
    );
  }
}
