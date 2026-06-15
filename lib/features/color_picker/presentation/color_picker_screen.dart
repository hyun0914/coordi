import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/color_picker/providers/color_picker_provider.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation_service.dart';
import 'package:coordi/features/recommendation/presentation/recommendation_screen.dart';

// ─── 화면 진입점 ────────────────────────────────────────────────────────────────

class ColorPickerScreen extends ConsumerStatefulWidget {
  const ColorPickerScreen({super.key, required this.categories});

  /// 색상을 입력할 카테고리 목록. 순서대로 한 단계씩 색상을 선택한다.
  final List<ClothingCategory> categories;

  @override
  ConsumerState<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends ConsumerState<ColorPickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// 현재 색상 선택 중인 카테고리 인덱스.
  int _currentStep = 0;

  /// 각 단계에서 확정된 색상 (길이 = 완료된 단계 수).
  final List<Color> _pickedColors = [];

  /// 사용자가 명시적으로 선택한 포인트 카테고리 (null = 기본값 socks).
  ClothingCategory? _pointCategory;

  ClothingCategory get _currentCategory => widget.categories[_currentStep];
  bool get _isLastStep => _currentStep == widget.categories.length - 1;

  /// 추천 대상 카테고리 (입력 카테고리 제외).
  List<ClothingCategory> get _targetCats => ClothingCategory.values
      .where((c) => !widget.categories.contains(c))
      .toList();

  /// 유효한 포인트 카테고리. 대상 밖이거나 비어있으면 socks 또는 첫 번째 대상으로 대체.
  ClothingCategory get _effectivePoint {
    final targets = _targetCats;
    if (targets.isEmpty) return ClothingCategory.socks; // UI에서 6개 이하로 막지만 방어적 처리
    if (_pointCategory != null && targets.contains(_pointCategory)) {
      return _pointCategory!;
    }
    return targets.contains(ClothingCategory.socks)
        ? ClothingCategory.socks
        : targets.first;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() => setState(() {});

  Color get _activeColor {
    if (_tabController.index == 0) return ref.read(wheelColorProvider);
    return ref.read(selectedExtractedColorProvider) ??
        ref.read(wheelColorProvider);
  }

  /// 현재 단계 색상 확정 후 다음 단계로 이동.
  void _onNextStep() {
    final color = _activeColor; // 상태 변경 전에 명시적 캡처 (탭 인덱스·provider 리셋보다 먼저)
    _pickedColors.add(color);
    _tabController.animateTo(0);
    ref.read(wheelColorProvider.notifier).state = const Color(0xFF5C6BC0);
    ref.read(selectedExtractedColorProvider.notifier).state = null;
    ref.read(pickedImageBytesProvider.notifier).state = null;
    ref.read(extractedColorsProvider.notifier).state = [];
    setState(() => _currentStep++);
  }

  /// 이전 단계로 돌아감. 마지막으로 확정된 색상을 색상환에 복원.
  void _goToPreviousStep() {
    final prevColor = _pickedColors.isNotEmpty ? _pickedColors.removeLast() : null;
    setState(() => _currentStep--);
    _tabController.animateTo(0);
    ref.read(wheelColorProvider.notifier).state =
        prevColor ?? const Color(0xFF5C6BC0);
    ref.read(selectedExtractedColorProvider.notifier).state = null;
    ref.read(pickedImageBytesProvider.notifier).state = null;
    ref.read(extractedColorsProvider.notifier).state = [];
  }

  /// 마지막 단계에서 추천 결과 화면으로 이동.
  void _onConfirm() {
    final colors = [..._pickedColors, _activeColor];
    final inputs = List.generate(
      colors.length,
      (i) => (widget.categories[i], colors[i]),
    );
    final recommendation = const ColorRecommendationService().recommend(
      inputs,
      pointCategory: _effectivePoint,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(recommendation: recommendation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final canProceed = _tabController.index == 0 ||
        ref.watch(selectedExtractedColorProvider) != null;

    // 다중 단계에서 시스템 뒤로가기 → 화면 닫힘 대신 이전 단계로 이동
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToPreviousStep();
      },
      child: Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: cs.surfaceTint,
        title: Text(
          widget.categories.length > 1
              ? '${_currentCategory.label} 색상 선택 (${_currentStep + 1}/${widget.categories.length})'
              : '${_currentCategory.label} 색상 선택',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
          labelStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: tt.labelLarge,
          dividerColor: cs.outlineVariant.withValues(alpha: 0.5),
          tabs: const [
            Tab(text: '색상환'),
            Tab(text: '사진에서 추출'),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TabBarView(
              controller: _tabController,
              children: const [
                _ColorWheelTab(),
                _ImageExtractionTab(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, cs, tt, canProceed),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ColorScheme cs, TextTheme tt, bool canProceed) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 마지막 단계에서만 포인트 카테고리 선택 표시
          if (_isLastStep) ...[
            _PointCategorySelector(
              targetCats: _targetCats,
              selected: _effectivePoint,
              onSelected: (cat) => setState(() => _pointCategory = cat),
            ),
            const SizedBox(height: 10),
          ],
          if (!_isLastStep)
            FilledButton.icon(
              onPressed: canProceed ? _onNextStep : null,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text('다음 (${_currentStep + 2}단계: ${widget.categories[_currentStep + 1].label})'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            )
          else
            FilledButton.icon(
              onPressed: canProceed ? _onConfirm : null,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('추천 받기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 포인트 카테고리 선택기 ──────────────────────────────────────────────────────

class _PointCategorySelector extends StatelessWidget {
  const _PointCategorySelector({
    required this.targetCats,
    required this.selected,
    required this.onSelected,
  });

  final List<ClothingCategory> targetCats;
  final ClothingCategory selected;
  final ValueChanged<ClothingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '포인트 카테고리',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(채도 높은 색상 우선 추천)',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 우측 페이드로 "더 있다" 힌트 제공
        SizedBox(
          height: 36,
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...targetCats.map((cat) {
                      final isSelected = cat == selected;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat.label),
                          selected: isSelected,
                          onSelected: (_) => onSelected(cat),
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
                        ),
                      );
                    }),
                    const SizedBox(width: 32), // 페이드 영역만큼 여백
                  ],
                ),
              ),
              // 우측 페이드 오버레이 — 스크롤 가능함을 암시
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 40,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          cs.surface.withValues(alpha: 0),
                          cs.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 탭 1: 색상환 ───────────────────────────────────────────────────────────────

class _ColorWheelTab extends ConsumerWidget {
  const _ColorWheelTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(wheelColorProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _hexFromColor(color),
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '색상환을 드래그하여 색상을 선택하세요',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 28),
          HueRingPicker(
            pickerColor: color,
            onColorChanged: (c) =>
                ref.read(wheelColorProvider.notifier).state = c,
            displayThumbColor: true,
            enableAlpha: false,
            colorPickerHeight: 280,
          ),
        ],
      ),
    );
  }
}

// ─── 탭 2: 사진에서 추출 ────────────────────────────────────────────────────────

class _ImageExtractionTab extends ConsumerWidget {
  const _ImageExtractionTab();

  Future<void> _pickAndExtract(WidgetRef ref) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (file == null) return;

    ref.read(isExtractingProvider.notifier).state = true;
    ref.read(extractedColorsProvider.notifier).state = const [];
    ref.read(selectedExtractedColorProvider.notifier).state = null;

    try {
      final bytes = await file.readAsBytes();
      ref.read(pickedImageBytesProvider.notifier).state = bytes;

      final generator = await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        maximumColorCount: 8,
      );

      final colors = <Color>[];
      if (generator.dominantColor != null) {
        colors.add(generator.dominantColor!.color);
      }
      for (final pc in generator.paletteColors) {
        if (!colors.contains(pc.color)) colors.add(pc.color);
        if (colors.length >= 6) break;
      }

      ref.read(extractedColorsProvider.notifier).state = colors;
      if (colors.isNotEmpty) {
        ref.read(selectedExtractedColorProvider.notifier).state = colors.first;
      }
    } catch (e) {
      debugPrint('[Coordi] 팔레트 추출 실패: $e');
    } finally {
      ref.read(isExtractingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes         = ref.watch(pickedImageBytesProvider);
    final colors        = ref.watch(extractedColorsProvider);
    final selectedColor = ref.watch(selectedExtractedColorProvider);
    final isExtracting  = ref.watch(isExtractingProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bytes == null)
            _UploadPlaceholder(onTap: () => _pickAndExtract(ref))
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                bytes,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _pickAndExtract(ref),
                icon: const Icon(Icons.refresh, size: 15),
                label: const Text('다른 이미지 선택'),
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isExtracting)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: cs.primary),
                      const SizedBox(height: 14),
                      Text(
                        '색상 추출 중...',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (colors.isNotEmpty) ...[
              Text(
                '추출된 색상',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.55),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors
                    .map((c) => _PaletteChip(
                          color: c,
                          isSelected: c == selectedColor,
                          onTap: () => ref
                              .read(selectedExtractedColorProvider.notifier)
                              .state = c,
                        ))
                    .toList(),
              ),
              if (selectedColor != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: selectedColor.withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hexFromColor(selectedColor),
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

// ─── 이미지 미선택 업로드 영역 ───────────────────────────────────────────────────

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.22),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 52, color: cs.primary),
            const SizedBox(height: 14),
            Text(
              '이미지 선택',
              style: tt.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '갤러리에서 옷 사진을 선택하면\n대표 색상을 자동으로 추출합니다.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.48),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 팔레트 칩 ──────────────────────────────────────────────────────────────────

class _PaletteChip extends StatelessWidget {
  const _PaletteChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? cs.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.55 : 0.30),
              blurRadius: isSelected ? 12 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isSelected
            ? Icon(Icons.check, color: _contrastColor(color), size: 22)
            : null,
      ),
    );
  }

  Color _contrastColor(Color bg) =>
      bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
}

// ─── 유틸 ───────────────────────────────────────────────────────────────────────

String _hexFromColor(Color c) {
  final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '#$r$g$b'.toUpperCase();
}
