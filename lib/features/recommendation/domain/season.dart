import 'reference_colors.dart';

/// 계절 톤. 선택하면 추천이 해당 계절에 어울리는 색상 위주로 좁혀진다.
enum Season {
  spring('봄', '밝고 화사한 파스텔', {
    ReferenceColor.pink,
    ReferenceColor.yellow,
    ReferenceColor.lightBlue,
    ReferenceColor.cream,
    ReferenceColor.beige,
    ReferenceColor.white,
  }),
  summer('여름', '시원하고 가벼운 색', {
    ReferenceColor.white,
    ReferenceColor.lightBlue,
    ReferenceColor.cream,
    ReferenceColor.beige,
    ReferenceColor.denimBlue,
    ReferenceColor.gray,
  }),
  autumn('가을', '깊이 있는 어스톤', {
    ReferenceColor.brown,
    ReferenceColor.khaki,
    ReferenceColor.burgundy,
    ReferenceColor.beige,
    ReferenceColor.orange,
    ReferenceColor.cream,
  }),
  winter('겨울', '짙고 차분한 색', {
    ReferenceColor.black,
    ReferenceColor.charcoal,
    ReferenceColor.navy,
    ReferenceColor.gray,
    ReferenceColor.burgundy,
    ReferenceColor.white,
  });

  const Season(this.label, this.description, this.colors);

  final String label;
  final String description;

  /// 이 계절에 어울리는 기준 색상.
  final Set<ReferenceColor> colors;
}
