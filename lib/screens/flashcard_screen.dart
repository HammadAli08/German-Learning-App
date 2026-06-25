import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/gloss_strip.dart';
import '../widgets/hairline_divider.dart';

class FlashcardScreen extends ConsumerWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(flashcardProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  Text('Flashcards', style: AppTextStyles.screenTitle(size: 22)),
                  const Spacer(),
                  if (state.hasCards && !state.isComplete)
                    Text(
                      '${state.currentIndex + 1} / ${state.dueCards.length}',
                      style: AppTextStyles.label(size: 13, color: AppColors.inkMuted),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.isComplete || !state.hasCards
                  ? _buildComplete(ref, state.dueCards.isEmpty)
                  : _buildCard(ref, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplete(WidgetRef ref, bool noDueCards) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              noDueCards ? Icons.inbox_outlined : Icons.check_circle_outline,
              color: AppColors.teal,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              noDueCards
                  ? 'No cards due.\nSave phrases to start reviewing!'
                  : 'All done for now!\nGreat review session.',
              style: AppTextStyles.body(size: 15, color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            if (!noDueCards) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(flashcardProvider.notifier).reset(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cobalt,
                  side: const BorderSide(color: AppColors.cobalt),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Review again', style: AppTextStyles.bodyMedium(size: 14)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(WidgetRef ref, FlashcardState state) {
    final card = state.currentCard!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.paper,
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(card.englishText,
                      style: AppTextStyles.body(size: 18, color: AppColors.ink),
                      textAlign: TextAlign.center),
                  if (state.showAnswer) ...[
                    const SizedBox(height: 32),
                    const HairlineDivider(),
                    const SizedBox(height: 32),
                    Text(card.germanInformal,
                        style: AppTextStyles.germanPhrase(size: 26),
                        textAlign: TextAlign.center),
                    if (card.wordGloss.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      GlossStrip(glossItems: card.wordGloss),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!state.showAnswer)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => ref.read(flashcardProvider.notifier).showAnswer(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cobalt,
                  side: const BorderSide(color: AppColors.cobalt),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Show answer', style: AppTextStyles.bodyMedium(size: 15)),
              ),
            )
          else
            Row(
              children: [
                Expanded(child: _RatingButton(label: 'Hard', color: AppColors.brick,
                    onTap: () => ref.read(flashcardProvider.notifier).rate(0))),
                const SizedBox(width: 12),
                Expanded(child: _RatingButton(label: 'Medium', color: AppColors.mustard,
                    onTap: () => ref.read(flashcardProvider.notifier).rate(1))),
                const SizedBox(width: 12),
                Expanded(child: _RatingButton(label: 'Easy', color: AppColors.teal,
                    onTap: () => ref.read(flashcardProvider.notifier).rate(2))),
              ],
            ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RatingButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: AppTextStyles.bodyMedium(size: 14, color: color),
            textAlign: TextAlign.center),
      ),
    );
  }
}
