import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// autoDispose: ColorPickerScreen이 스택에서 사라지면 자동 해제.
// 동일 세션 내 RecommendationScreen push/pop 중에는 화면이 살아있으므로 상태 유지됨.
// 뒤로가기로 HomeScreen까지 벗어나면 다음 진입 시 초기값으로 재시작.

/// HSV 색상환 탭에서 실시간으로 선택 중인 색상.
/// HSVColor로 저장하여 흰색/검정 구역에서도 hue가 손실되지 않도록 함.
final wheelColorProvider = StateProvider.autoDispose<HSVColor>(
  (ref) => const HSVColor.fromAHSV(1.0, 231, 0.52, 0.75), // ≈ #5C6BC0
);

/// 이미지 추출 탭 — 선택된 이미지 바이트 (웹 호환: XFile.readAsBytes()).
final pickedImageBytesProvider =
    StateProvider.autoDispose<Uint8List?>((ref) => null);

/// 이미지 추출 탭 — palette_generator 로 추출된 색상 목록.
final extractedColorsProvider =
    StateProvider.autoDispose<List<Color>>((ref) => const []);

/// 이미지 추출 탭 — 팔레트 칩에서 최종 선택된 색상.
final selectedExtractedColorProvider =
    StateProvider.autoDispose<Color?>((ref) => null);

/// 이미지 추출 탭 — 추출 진행 중 여부.
final isExtractingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
