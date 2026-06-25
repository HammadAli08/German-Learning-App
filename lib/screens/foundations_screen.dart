import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/foundations_data.dart';
import '../providers/foundations_provider.dart';
import '../widgets/hairline_divider.dart';
import 'lesson_detail_screen.dart';

class FoundationsScreen extends ConsumerWidget {
  const FoundationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(foundationsProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Foundations', style: AppTextStyles.screenTitle(size: 22)),
                  const SizedBox(height: 4),
                  Text(
                    'A1 beginner track — Goethe Institut order',
                    style: AppTextStyles.label(size: 13, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lesson 1 suggestion banner ───────────────────────────────
            if (!completed.contains(1))
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cobalt.withValues(alpha: 0.06),
                    border: Border.all(
                        color: AppColors.cobalt.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.cobalt, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Start with Lesson 1 to learn sounds and pronunciation — it makes every other lesson easier.',
                          style: AppTextStyles.body(
                              size: 13, color: AppColors.cobalt),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const HairlineDivider(),

            // ── Lesson list ───────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: kFoundationsLessons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final lesson = kFoundationsLessons[i];
                  final isDone = completed.contains(lesson.id);
                  return _LessonCard(
                    lesson: lesson,
                    isDone: isDone,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonDetailScreen(lesson: lesson),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final FoundationsLesson lesson;
  final bool isDone;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(
            color: isDone
                ? AppColors.teal.withValues(alpha: 0.4)
                : AppColors.hairline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Lesson number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.teal.withValues(alpha: 0.1)
                    : AppColors.cobalt.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? AppColors.teal.withValues(alpha: 0.4)
                      : AppColors.cobalt.withValues(alpha: 0.3),
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.teal, size: 18)
                  : Center(
                      child: Text(
                        '${lesson.id}',
                        style: AppTextStyles.bodyMedium(
                            size: 14, color: AppColors.cobalt),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      style: AppTextStyles.bodyMedium(size: 15)),
                  const SizedBox(height: 2),
                  Text(lesson.subtitle,
                      style: AppTextStyles.label(
                          size: 12, color: AppColors.inkMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.inkMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
