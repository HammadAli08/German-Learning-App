import 'package:hive/hive.dart';

part 'word_gloss.g.dart';

@HiveType(typeId: 1)
class WordGloss {
  @HiveField(0)
  final String de;

  @HiveField(1)
  final String en;

  const WordGloss({required this.de, required this.en});

  factory WordGloss.fromJson(Map<String, dynamic> json) => WordGloss(
        de: json['de'] as String? ?? '',
        en: json['en'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'de': de, 'en': en};
}
