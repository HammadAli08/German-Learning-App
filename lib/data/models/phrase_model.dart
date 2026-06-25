import 'package:hive_flutter/hive_flutter.dart';
import 'word_gloss.dart';

part 'phrase_model.g.dart';

@HiveType(typeId: 0)
class PhraseModel extends HiveObject {
  @HiveField(0)
  String englishText;

  @HiveField(1)
  String germanInformal;

  @HiveField(2)
  String germanFormal;

  @HiveField(3)
  List<WordGloss> wordGloss;

  @HiveField(4)
  String grammarNote;

  @HiveField(5)
  String alternatePhrasing;

  @HiveField(6)
  DateTime dateAdded;

  @HiveField(7)
  DateTime lastReviewed;

  /// SM-2 interval in days
  @HiveField(8)
  int intervalDays;

  /// SM-2 ease factor (initial: 2.5)
  @HiveField(9)
  double easeFactor;

  /// Cached WAV bytes for quick replay — not persisted, nullable
  @HiveField(10)
  String? cachedAudioPath;

  /// 'personal' (recorded by user) or 'foundations' (from Foundations lessons)
  @HiveField(11)
  String category;

  PhraseModel({
    required this.englishText,
    required this.germanInformal,
    required this.germanFormal,
    required this.wordGloss,
    required this.grammarNote,
    required this.alternatePhrasing,
    required this.dateAdded,
    required this.lastReviewed,
    this.intervalDays = 1,
    this.easeFactor = 2.5,
    this.cachedAudioPath,
    this.category = 'personal',
  });

  /// Whether this card is due for review today
  bool get isDue {
    final effectiveInterval = intervalDays < 1 ? 1 : intervalDays;
    final dueDate = lastReviewed.add(Duration(days: effectiveInterval));
    final now = DateTime.now();
    return now.isAfter(dueDate) || now.isAtSameMomentAs(dueDate);
  }
}
