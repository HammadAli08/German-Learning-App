import 'word_gloss.dart';

/// In-memory result from the full LLM tutoring pipeline.
class TranslationResult {
  final String englishText;
  final String germanInformal;
  final String germanFormal;
  final List<WordGloss> wordGloss;
  final String grammarNote;
  final String alternatePhrasing;

  /// Raw WAV bytes from TTS — not persisted
  final List<int>? audioBytes;
  final String? audioFilePath;

  const TranslationResult({
    required this.englishText,
    required this.germanInformal,
    required this.germanFormal,
    required this.wordGloss,
    required this.grammarNote,
    required this.alternatePhrasing,
    this.audioBytes,
    this.audioFilePath,
  });

  /// Lightweight path result — no gloss/grammar
  factory TranslationResult.lightweight({
    required String englishText,
    required String germanInformal,
    List<int>? audioBytes,
    String? audioFilePath,
  }) =>
      TranslationResult(
        englishText: englishText,
        germanInformal: germanInformal,
        germanFormal: germanInformal, // same for lightweight
        wordGloss: const [],
        grammarNote: '',
        alternatePhrasing: '',
        audioBytes: audioBytes,
        audioFilePath: audioFilePath,
      );

  factory TranslationResult.fromLlmJson({
    required String englishText,
    required Map<String, dynamic> json,
    List<int>? audioBytes,
    String? audioFilePath,
  }) {
    final glossList = (json['word_gloss'] as List<dynamic>? ?? [])
        .map((e) => WordGloss.fromJson(e as Map<String, dynamic>))
        .toList();

    return TranslationResult(
      englishText: englishText,
      germanInformal: json['german_informal'] as String? ?? '',
      germanFormal: json['german_formal'] as String? ?? '',
      wordGloss: glossList,
      grammarNote: json['grammar_note'] as String? ?? '',
      alternatePhrasing: json['alternate_phrasing'] as String? ?? '',
      audioBytes: audioBytes,
      audioFilePath: audioFilePath,
    );
  }

  TranslationResult copyWith({
    String? audioFilePath,
    List<int>? audioBytes,
  }) =>
      TranslationResult(
        englishText: englishText,
        germanInformal: germanInformal,
        germanFormal: germanFormal,
        wordGloss: wordGloss,
        grammarNote: grammarNote,
        alternatePhrasing: alternatePhrasing,
        audioBytes: audioBytes ?? this.audioBytes,
        audioFilePath: audioFilePath ?? this.audioFilePath,
      );
}
