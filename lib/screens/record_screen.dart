import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/foundations_data.dart';
import '../providers/pipeline_provider.dart';
import '../providers/phrasebook_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/foundations_provider.dart';
import '../widgets/record_button.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/word_play_button.dart';
import 'result_screen.dart';
import 'lesson_detail_screen.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    final pipeline = ref.watch(pipelineProvider);
    final recentPhrases =
        ref.watch(phrasebookProvider.select((p) => p.take(5).toList()));
    final settings = ref.watch(settingsProvider).valueOrNull;
    final isRecording = pipeline.stage == PipelineStage.recording;
    // Watch foundations progress so the nudge updates when lessons are completed
    ref.watch(foundationsProvider);
    final nextFoundationsLesson =
        ref.read(foundationsProvider.notifier).nextLesson;

    // Navigate to result when done
    ref.listen(pipelineProvider, (prev, next) {
      if (next.stage == PipelineStage.done && next.result != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  Text('GermanLoop', style: AppTextStyles.screenTitle(size: 22)),
                  const Spacer(),
                  if (settings?.token.isEmpty ?? true)
                    GestureDetector(
                      onTap: () => _showTokenWarning(context),
                      child: const Icon(Icons.warning_amber_rounded,
                          color: AppColors.mustard, size: 22),
                    ),
                ],
              ),
            ),

            // ── Record Area ───────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecordButton(
                      isRecording: isRecording,
                      isLoading: pipeline.isLoading,
                      size: 88,
                      onTap: pipeline.isLoading ? null : _handleRecordTap,
                    ),
                    const SizedBox(height: 24),
                    if (pipeline.isLoading)
                      _buildStageIndicator(pipeline)
                    else if (pipeline.stage == PipelineStage.error)
                      _buildError(pipeline)
                    else
                      Text(
                        isRecording
                            ? 'Tap to stop recording'
                            : 'Say what you want to say in English.',
                        style: AppTextStyles.body(
                          size: 15,
                          color: AppColors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),

            // ── Recent Phrases ────────────────────────────────────────────
            if (recentPhrases.isNotEmpty) ...[
              const HairlineDivider(),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child:
                          Text('Recent', style: AppTextStyles.screenTitle(size: 16)),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: recentPhrases.length,
                        separatorBuilder: (_, __) =>
                            const HairlineDivider(indent: 24),
                        itemBuilder: (context, i) {
                          final phrase = recentPhrases[i];
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ResultScreen(phrase: phrase),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            title: Text(
                              phrase.englishText,
                              style: AppTextStyles.body(size: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              phrase.germanInformal,
                              style: AppTextStyles.body(
                                size: 12,
                                color: AppColors.inkMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ResultScreen(phrase: phrase),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.play_circle_outline_rounded,
                                color: AppColors.cobalt,
                                size: 26,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Feature 5: Foundations nudge card ─────────────────────────
            if (nextFoundationsLesson != null) ...[
              const HairlineDivider(),
              _FoundationsNudgeCard(lesson: nextFoundationsLesson),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleRecordTap() {
    final pipeline = ref.read(pipelineProvider);
    final notifier = ref.read(pipelineProvider.notifier);
    if (pipeline.stage == PipelineStage.recording) {
      notifier.stopRecordingAndProcess();
    } else if (pipeline.stage == PipelineStage.idle ||
        pipeline.stage == PipelineStage.error ||
        pipeline.stage == PipelineStage.done) {
      notifier.reset();
      notifier.startRecording();
    }
  }

  Widget _buildStageIndicator(PipelineState pipeline) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.cobalt,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              pipeline.stageLabel,
              style: AppTextStyles.label(size: 14, color: AppColors.cobalt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildError(PipelineState pipeline) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            pipeline.errorMessage ?? 'Something went wrong.',
            style: AppTextStyles.body(size: 13, color: AppColors.brick),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => ref.read(pipelineProvider.notifier).reset(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cobalt,
              side: const BorderSide(color: AppColors.cobalt),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Try again', style: AppTextStyles.bodyMedium(size: 14)),
          ),
        ],
      ),
    );
  }

  void _showTokenWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Add your Hugging Face token in Settings to get started.'),
      ),
    );
  }
}

// ── Feature 5: Foundations nudge card ────────────────────────────────────────

class _FoundationsNudgeCard extends StatelessWidget {
  final FoundationsLesson lesson;

  const _FoundationsNudgeCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final previewWord =
        lesson.items.isNotEmpty ? lesson.items.first.de : '';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lesson: lesson),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hairline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.school_outlined,
                  color: AppColors.cobalt, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Next: ${lesson.title}',
                  style: AppTextStyles.body(size: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (previewWord.isNotEmpty) ...[
                const SizedBox(width: 8),
                WordPlayButton(word: previewWord, size: 18),
              ],
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.inkMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
