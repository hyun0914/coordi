import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordi/core/constants/clothing_category.dart';
import 'package:coordi/features/recommendation/domain/reference_colors.dart';
import 'package:coordi/features/wardrobe/domain/wardrobe.dart';

/// 내 옷장. 기기 로컬(웹은 localStorage)에만 저장된다.
final wardrobeProvider = AsyncNotifierProvider<WardrobeNotifier, Wardrobe>(
  WardrobeNotifier.new,
);

class WardrobeNotifier extends AsyncNotifier<Wardrobe> {
  static const _storageKey = 'wardrobe_v1';

  late SharedPreferences _prefs;

  @override
  Future<Wardrobe> build() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return {};

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final category in ClothingCategory.values)
          if (json[category.name] case final List names)
            category: {
              // enum 이름 변경 등으로 복원할 수 없는 색상은 건너뛴다.
              for (final ref in ReferenceColor.values)
                if (names.contains(ref.name)) ref,
            },
      };
    } catch (_) {
      return {};
    }
  }

  /// [category]에 [color]가 없으면 추가하고, 있으면 제거한다.
  Future<void> toggle(ClothingCategory category, ReferenceColor color) async {
    final current = await future;
    final colors  = {...?current[category]};
    if (!colors.remove(color)) colors.add(color);

    final next = {...current, category: colors};
    await _prefs.setString(
      _storageKey,
      jsonEncode({
        for (final e in next.entries)
          e.key.name: [for (final c in e.value) c.name],
      }),
    );
    state = AsyncData(next);
  }
}
