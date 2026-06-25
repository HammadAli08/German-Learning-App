import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/foundations_data.dart';

/// Tracks which Foundations lessons the user has completed.
/// Backed by Hive box<bool>('foundations_progress').
/// Key format: 'lesson_N' where N is lesson.id (1–10).
class FoundationsNotifier extends Notifier<Set<int>> {
  Box<bool> get _box => Hive.box<bool>('foundations_progress');

  @override
  Set<int> build() {
    final completed = <int>{};
    for (final lesson in kFoundationsLessons) {
      if (_box.get('lesson_${lesson.id}') == true) {
        completed.add(lesson.id);
      }
    }
    return completed;
  }

  Future<void> markComplete(int lessonId) async {
    await _box.put('lesson_$lessonId', true);
    state = {...state, lessonId};
  }

  Future<void> markIncomplete(int lessonId) async {
    await _box.put('lesson_$lessonId', false);
    state = state.difference({lessonId});
  }

  bool isComplete(int lessonId) => state.contains(lessonId);

  /// Returns the next lesson the user hasn't completed yet, or null if all done.
  FoundationsLesson? get nextLesson {
    for (final lesson in kFoundationsLessons) {
      if (!state.contains(lesson.id)) return lesson;
    }
    return null;
  }
}

final foundationsProvider =
    NotifierProvider<FoundationsNotifier, Set<int>>(FoundationsNotifier.new);
