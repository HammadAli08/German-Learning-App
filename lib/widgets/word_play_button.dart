import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../services/word_tts_service.dart';

/// A small ▷ icon that speaks a single German word when tapped.
/// Uses the WordTtsService which caches audio in Hive.
class WordPlayButton extends ConsumerWidget {
  final String word;
  final double size;
  final Color color;

  const WordPlayButton({
    super.key,
    required this.word,
    this.size = 18,
    this.color = AppColors.cobalt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeWord = ref.watch(wordTtsProvider);
    final isThisWordPlaying = activeWord == word;
    final isAnyWordPlaying = activeWord != null;

    return GestureDetector(
      onTap: isAnyWordPlaying ? null : () => ref.read(wordTtsProvider.notifier).speak(word),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: isThisWordPlaying
            ? SizedBox(
                key: const ValueKey('loading'),
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 1.2,
                  color: color.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                key: const ValueKey('play'),
                Icons.play_circle_outline_rounded,
                size: size,
                color: isAnyWordPlaying ? color.withValues(alpha: 0.35) : color,
              ),
      ),
    );
  }
}
