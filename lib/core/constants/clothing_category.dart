enum ClothingCategory {
  top   ('상의',   true),
  bottom('하의',   true),
  outer ('아우터',  true),
  shoes ('신발',   false),
  socks ('양말',   false),
  hat   ('모자',   false),
  bag   ('가방',   false);

  const ClothingCategory(this.label, this.isMain);

  final String label;

  /// true = 기준색 입력 대상 (상의/하의/아우터)
  /// false = 추천 결과 대상만 (신발/양말/모자/가방)
  final bool isMain;

  static List<ClothingCategory> get mainCategories =>
      values.where((c) => c.isMain).toList();
}
