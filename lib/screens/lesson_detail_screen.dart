import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/foundations_data.dart';
import '../data/pronunciation_rules.dart';
import '../providers/foundations_provider.dart';
import '../providers/phrasebook_provider.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/word_play_button.dart';

class LessonDetailScreen extends ConsumerWidget {
  final FoundationsLesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(foundationsProvider).contains(lesson.id);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lesson ${lesson.id}',
          style: AppTextStyles.screenTitle(size: 18),
        ),
        actions: [
          // Mark complete / incomplete toggle
          GestureDetector(
            onTap: () async {
              if (completed) {
                await ref
                    .read(foundationsProvider.notifier)
                    .markIncomplete(lesson.id);
              } else {
                await ref
                    .read(foundationsProvider.notifier)
                    .markComplete(lesson.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: completed ? AppColors.teal : AppColors.inkMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    completed ? 'Done' : 'Mark done',
                    style: AppTextStyles.label(
                        size: 12,
                        color: completed ? AppColors.teal : AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + subtitle ─────────────────────────────────────────
            Text(lesson.title, style: AppTextStyles.germanPhrase(size: 22)),
            const SizedBox(height: 6),
            Text(lesson.subtitle,
                style: AppTextStyles.body(size: 14, color: AppColors.inkMuted)),
            const SizedBox(height: 24),
            const HairlineDivider(),
            const SizedBox(height: 24),

            // ── Lesson 1 special: alphabet chars + pronunciation rules ──
            if (lesson.primaryContent == LessonContentType.pronunciationRules)
              _PronunciationContent(lesson: lesson),

            // ── Conjugation tables (Lesson 4) ───────────────────────────
            if (lesson.conjugationTables.isNotEmpty) ...[
              if (lesson.items.isNotEmpty) ...[
                _SectionHeader('Pronouns'),
                const SizedBox(height: 12),
                _VocabList(items: lesson.items),
                const SizedBox(height: 24),
              ],
              for (final table in lesson.conjugationTables) ...[
                _SectionHeader('${table.infinitive} — ${table.infinitiveEn}'),
                const SizedBox(height: 12),
                _ConjugationTableWidget(table: table),
                const SizedBox(height: 24),
              ],
            ],

            // ── Word order examples (Lesson 5) ───────────────────────────
            if (lesson.primaryContent == LessonContentType.wordOrder) ...[
              _SectionHeader('Word Order Rules'),
              const SizedBox(height: 16),
              for (final ex in lesson.wordOrderExamples) ...[
                _WordOrderCard(example: ex),
                const SizedBox(height: 16),
              ],
            ],

            // ── Standard vocab list ──────────────────────────────────────
            if (lesson.primaryContent == LessonContentType.vocab &&
                lesson.items.isNotEmpty) ...[
              _SectionHeader('Vocabulary'),
              const SizedBox(height: 12),
              _VocabList(items: lesson.items),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Pronunciation content (Lesson 1) ─────────────────────────────────────────

class _PronunciationContent extends StatelessWidget {
  final FoundationsLesson lesson;
  const _PronunciationContent({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Special characters
        _SectionHeader('Special Characters'),
        const SizedBox(height: 12),
        for (final item in lesson.items) _LessonItemTile(item: item),

        const SizedBox(height: 24),
        const HairlineDivider(),
        const SizedBox(height: 24),

        // Full pronunciation rules list
        _SectionHeader('Pronunciation Rules'),
        const SizedBox(height: 12),
        for (final rule in kPronunciationRules)
          _PronunciationRuleTile(rule: rule),
      ],
    );
  }
}

class _PronunciationRuleTile extends StatelessWidget {
  final PronunciationRule rule;
  const _PronunciationRuleTile({required this.rule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pattern badge
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.mustard.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              rule.pattern,
              style: AppTextStyles.glossDe(size: 13)
                  .copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.explanation,
                    style: AppTextStyles.body(size: 13, color: AppColors.ink)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('e.g. ',
                        style: AppTextStyles.label(
                            size: 12, color: AppColors.inkMuted)),
                    Text(rule.exampleWord,
                        style: AppTextStyles.glossDe(size: 12)
                            .copyWith(color: AppColors.cobalt)),
                    const SizedBox(width: 4),
                    WordPlayButton(word: rule.exampleWord, size: 15),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vocab list ────────────────────────────────────────────────────────────────

class _VocabList extends StatelessWidget {
  final List<LessonItem> items;

  const _VocabList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _LessonItemTile(item: items[i]),
          if (i < items.length - 1) const HairlineDivider(indent: 0),
        ],
      ],
    );
  }
}

class _LessonItemTile extends ConsumerWidget {
  final LessonItem item;

  const _LessonItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = matchingRules(item.de);
    // Watch phrasebook to react to save/unsave
    final isSaved = ref.watch(
      phrasebookProvider.select(
        (_) => ref.read(phrasebookProvider.notifier).isFoundationsWordSaved(item.de),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // German word + rule marker dot
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(item.de,
                          style: AppTextStyles.germanPhrase(size: 20)),
                    ),
                    if (rules.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showRules(context, rules),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.mustard,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Play button
              WordPlayButton(word: item.de, size: 20),
              const SizedBox(width: 8),
              // Save to review button
              GestureDetector(
                onTap: isSaved
                    ? null
                    : () async {
                        await ref
                            .read(phrasebookProvider.notifier)
                            .saveFoundationsWord(
                              de: item.de,
                              en: item.en,
                              note: item.note,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '"${item.de}" added to flashcards.'),
                            ),
                          );
                        }
                      },
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_add_outlined,
                  color: isSaved ? AppColors.teal : AppColors.inkMuted,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.en,
              style: AppTextStyles.body(size: 14, color: AppColors.inkMuted)),
          if (item.note != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mustard.withValues(alpha: 0.08),
                border:
                    Border.all(color: AppColors.mustard.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.mustard, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(item.note!,
                        style: AppTextStyles.grammarNote(size: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRules(BuildContext context, List<PronunciationRule> rules) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppColors.hairline),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pronunciation tips for "${item.de}"',
                style: AppTextStyles.bodyMedium(size: 15)),
            const SizedBox(height: 16),
            ...rules.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mustard.withValues(alpha: 0.12),
                          border: Border.all(
                              color: AppColors.mustard.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(r.pattern,
                            style: AppTextStyles.glossDe(size: 12)
                                .copyWith(color: AppColors.ink)),
                      ),
                      const SizedBox(height: 4),
                      Text(r.explanation,
                          style: AppTextStyles.body(
                              size: 13, color: AppColors.inkMuted)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Conjugation table ─────────────────────────────────────────────────────────

class _ConjugationTableWidget extends StatelessWidget {
  final ConjugationTable table;
  const _ConjugationTableWidget({required this.table});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          for (int i = 0; i < table.rows.length; i++) ...[
            if (i > 0) const HairlineDivider(indent: 0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Pronoun
                  SizedBox(
                    width: 120,
                    child: Text(table.rows[i][0],
                        style: AppTextStyles.label(
                            size: 13, color: AppColors.inkMuted)),
                  ),
                  // Conjugated form
                  Expanded(
                    child: Row(
                      children: [
                        Text(table.rows[i][1],
                            style: AppTextStyles.germanPhrase(size: 16)),
                        const SizedBox(width: 6),
                        WordPlayButton(word: table.rows[i][1], size: 16),
                      ],
                    ),
                  ),
                  // English
                  Text(table.rows[i][2],
                      style:
                          AppTextStyles.body(size: 12, color: AppColors.inkMuted)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Word order card (Lesson 5) ────────────────────────────────────────────────

class _WordOrderCard extends StatelessWidget {
  final WordOrderExample example;
  const _WordOrderCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // German sentence
          Row(
            children: [
              Expanded(
                child: Text(example.de,
                    style: AppTextStyles.germanPhrase(size: 18)),
              ),
              WordPlayButton(word: example.de, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(example.en,
              style: AppTextStyles.body(size: 14, color: AppColors.inkMuted)),
          const SizedBox(height: 12),
          // Rule note (mustard callout)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mustard.withValues(alpha: 0.08),
              border:
                  Border.all(color: AppColors.mustard.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.mustard, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(example.ruleNote,
                      style: AppTextStyles.grammarNote(size: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label(size: 11, color: AppColors.inkMuted)
          .copyWith(letterSpacing: 0.8),
    );
  }
}
