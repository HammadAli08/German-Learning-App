import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/phrase_model.dart';
import '../data/models/translation_result.dart';

const _phrasesBox = 'phrases';

class PhrasebookNotifier extends Notifier<List<PhraseModel>> {
  Box<PhraseModel> get _box => Hive.box<PhraseModel>(_phrasesBox);

  @override
  List<PhraseModel> build() {
    return _sortedPhrases();
  }

  List<PhraseModel> _sortedPhrases() {
    final phrases = _box.values.toList();
    phrases.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return phrases;
  }

  Future<PhraseModel> savePhrase(TranslationResult result) async {
    final now = DateTime.now();
    final phrase = PhraseModel(
      englishText: result.englishText,
      germanInformal: result.germanInformal,
      germanFormal: result.germanFormal,
      wordGloss: result.wordGloss,
      grammarNote: result.grammarNote,
      alternatePhrasing: result.alternatePhrasing,
      dateAdded: now,
      lastReviewed: now,
      cachedAudioPath: result.audioFilePath,
    );
    await _box.add(phrase);
    state = _sortedPhrases();
    return phrase;
  }

  Future<void> deletePhrase(PhraseModel phrase) async {
    await phrase.delete();
    state = _sortedPhrases();
  }

  void refresh() {
    state = _sortedPhrases();
  }

  List<PhraseModel> search(String query) {
    if (query.isEmpty) return state;
    final q = query.toLowerCase();
    return state.where((p) =>
        p.englishText.toLowerCase().contains(q) ||
        p.germanInformal.toLowerCase().contains(q)).toList();
  }

  List<PhraseModel> get recentFive => state.take(5).toList();
}

final phrasebookProvider = NotifierProvider<PhrasebookNotifier, List<PhraseModel>>(
  PhrasebookNotifier.new,
);
