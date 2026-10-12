import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coordi/features/favorites/domain/saved_coordi.dart';
import 'package:coordi/features/recommendation/domain/color_recommendation.dart';

/// 즐겨찾기 목록 (최신 저장순). 기기 로컬(웹은 localStorage)에만 저장된다.
final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<SavedCoordi>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<SavedCoordi>> {
  static const _storageKey = 'favorites_v1';

  late SharedPreferences _prefs;

  @override
  Future<List<SavedCoordi>> build() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getStringList(_storageKey) ?? const [];

    final items = <SavedCoordi>[];
    for (final entry in raw) {
      try {
        items.add(
          SavedCoordi.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } catch (_) {
        // enum 이름 변경 등으로 복원할 수 없는 항목은 건너뛴다.
      }
    }
    return items;
  }

  /// 추천 결과를 저장하고 생성된 id를 반환한다.
  Future<String> add(ColorRecommendation recommendation) async {
    final now = DateTime.now();
    final saved = SavedCoordi(
      id: now.microsecondsSinceEpoch.toString(),
      savedAt: now,
      recommendation: recommendation,
    );
    await _save([saved, ...await future]);
    return saved.id;
  }

  Future<void> remove(String id) async {
    await _save([
      for (final item in await future)
        if (item.id != id) item,
    ]);
  }

  /// 삭제 실행취소용. 원래 저장 시각 기준 위치로 되돌린다.
  Future<void> restore(SavedCoordi saved) async {
    final current = await future;
    if (current.any((item) => item.id == saved.id)) return;
    await _save(
      [...current, saved]..sort((a, b) => b.savedAt.compareTo(a.savedAt)),
    );
  }

  Future<void> _save(List<SavedCoordi> items) async {
    await _prefs.setStringList(
      _storageKey,
      [for (final item in items) jsonEncode(item.toJson())],
    );
    state = AsyncData(items);
  }
}
