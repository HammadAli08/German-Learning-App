import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/phrase_model.dart';
import '../services/sr_service.dart';

const _phrasesBox = 'phrases';

enum FlashcardFilter { all, personal, foundations }

class FlashcardState {
  final List<PhraseModel> dueCards;
  final int currentIndex;
  final bool showAnswer;
  final FlashcardFilter filter;

  const FlashcardState({
    this.dueCards = const [],
    this.currentIndex = 0,
    this.showAnswer = false,
    this.filter = FlashcardFilter.all,
  });

  PhraseModel? get currentCard =>
      dueCards.isEmpty ? null : dueCards[currentIndex];

  bool get hasCards => dueCards.isNotEmpty;
  bool get isComplete => currentIndex >= dueCards.length;

  FlashcardState copyWith({
    List<PhraseModel>? dueCards,
    int? currentIndex,
    bool? showAnswer,
    FlashcardFilter? filter,
  }) =>
      FlashcardState(
        dueCards: dueCards ?? this.dueCards,
        currentIndex: currentIndex ?? this.currentIndex,
        showAnswer: showAnswer ?? this.showAnswer,
        filter: filter ?? this.filter,
      );
}

class FlashcardNotifier extends Notifier<FlashcardState> {
  final _sr = SRService();

  Box<PhraseModel> get _box => Hive.box<PhraseModel>(_phrasesBox);

  @override
  FlashcardState build() {
    final due = _filteredDue(FlashcardFilter.all);
    return FlashcardState(dueCards: due);
  }

  List<PhraseModel> _filteredDue(FlashcardFilter filter) {
    var all = _box.values.where((p) => p.isDue);
    if (filter == FlashcardFilter.personal) {
      all = all.where((p) => p.category == 'personal');
    } else if (filter == FlashcardFilter.foundations) {
      all = all.where((p) => p.category == 'foundations');
    }
    return all.toList()
      ..sort((a, b) => a.lastReviewed.compareTo(b.lastReviewed));
  }

  void setFilter(FlashcardFilter filter) {
    final due = _filteredDue(filter);
    state = FlashcardState(dueCards: due, filter: filter);
  }

  void showAnswer() {
    state = state.copyWith(showAnswer: true);
  }

  /// [quality]: 0 = Hard, 1 = Medium, 2 = Easy
  void rate(int quality) {
    final card = state.currentCard;
    if (card == null) return;
    _sr.applyRating(card, quality);
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      showAnswer: false,
    );
  }

  void reset() {
    final due = _filteredDue(state.filter);
    state = FlashcardState(dueCards: due, filter: state.filter);
  }
}

final flashcardProvider = NotifierProvider<FlashcardNotifier, FlashcardState>(
  FlashcardNotifier.new,
);
