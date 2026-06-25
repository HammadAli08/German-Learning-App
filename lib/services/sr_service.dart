import '../data/models/phrase_model.dart';

/// SM-2 Spaced Repetition algorithm.
///
/// Quality ratings map:
///   0 = Hard (blackout/complete fail)
///   1 = Medium (significant difficulty)
///   2 = Easy (correct with little effort)
class SRService {
  static const double _minEaseFactor = 1.3;

  /// Update a [PhraseModel] in-place with new SM-2 values after a review.
  ///
  /// [quality] must be 0 (Hard), 1 (Medium), or 2 (Easy).
  void applyRating(PhraseModel phrase, int quality) {
    // Map app ratings to SM-2 quality (0-5 scale)
    final sm2Quality = switch (quality) {
      0 => 1, // Hard → near-fail
      1 => 3, // Medium → correct but difficult
      _ => 5, // Easy → perfect
    };

    // Update ease factor
    final newEase = phrase.easeFactor +
        (0.1 - (5 - sm2Quality) * (0.08 + (5 - sm2Quality) * 0.02));
    phrase.easeFactor = newEase.clamp(_minEaseFactor, double.infinity);

    // Update interval
    if (sm2Quality < 3) {
      // Failed — reset to 1 day
      phrase.intervalDays = 1;
    } else if (phrase.intervalDays == 1) {
      phrase.intervalDays = 6;
    } else {
      phrase.intervalDays = (phrase.intervalDays * phrase.easeFactor).round();
    }

    phrase.lastReviewed = DateTime.now();
    phrase.save();
  }

  /// Returns the interval in days for display.
  String intervalLabel(PhraseModel phrase) {
    final d = phrase.intervalDays;
    if (d == 1) return 'tomorrow';
    if (d < 7) return 'in $d days';
    if (d < 14) return 'in 1 week';
    return 'in ${(d / 7).round()} weeks';
  }
}
