import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/translation_result.dart';
import '../providers/pipeline_provider.dart';
import '../providers/phrasebook_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/gloss_strip.dart';
import '../widgets/hairline_divider.dart';
import '../widgets/pill_button.dart';
import '../widgets/stage_label.dart';
import '../data/models/phrase_model.dart';
import 'practice_screen.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final PhraseModel? phrase;
  const ResultScreen({super.key, this.phrase});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  bool _useFormal = false;
  bool _saved = false;
  TranslationResult? _customResult;

  // Animation controllers for the reveal sequence
  late AnimationController _transcriptCtrl;
  late AnimationController _phraseCtrl;
  late AnimationController _underlineCtrl;
  late AnimationController _restCtrl;

  late Animation<double> _transcriptOpacity;
  late Animation<Offset> _phraseSlide;
  late Animation<double> _phraseOpacity;
  late Animation<double> _underlineWidth;
  late Animation<double> _restOpacity;

  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();

    if (widget.phrase != null) {
      _saved = true;
      _customResult = TranslationResult(
        englishText: widget.phrase!.englishText,
        germanInformal: widget.phrase!.germanInformal,
        germanFormal: widget.phrase!.germanFormal,
        wordGloss: widget.phrase!.wordGloss,
        grammarNote: widget.phrase!.grammarNote,
        alternatePhrasing: widget.phrase!.alternatePhrasing,
        audioFilePath: widget.phrase!.cachedAudioPath,
      );
    }

    _transcriptCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _phraseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _underlineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _restCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _transcriptOpacity =
        CurvedAnimation(parent: _transcriptCtrl, curve: Curves.easeOut);
    _phraseSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _phraseCtrl, curve: Curves.easeOut));
    _phraseOpacity =
        CurvedAnimation(parent: _phraseCtrl, curve: Curves.easeOut);
    _underlineWidth =
        CurvedAnimation(parent: _underlineCtrl, curve: Curves.easeOut);
    _restOpacity = CurvedAnimation(parent: _restCtrl, curve: Curves.easeOut);
  }

  void _startRevealAnimation(BuildContext context) {
    if (_animationStarted) return;
    _animationStarted = true;

    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion) {
      _transcriptCtrl.value = 1;
      _phraseCtrl.value = 1;
      _underlineCtrl.value = 1;
      _restCtrl.value = 1;
      return;
    }

    // 1. Transcript fades in
    _transcriptCtrl.forward().then((_) {
      // 2. 150ms beat
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        // 3. Phrase slides up + underline draws
        _phraseCtrl.forward();
        _underlineCtrl.forward();
        // 4. Rest fades after phrase + gloss tiles (handled by GlossStrip)
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _restCtrl.forward();
        });
      });
    });
  }

  @override
  void dispose() {
    _transcriptCtrl.dispose();
    _phraseCtrl.dispose();
    _underlineCtrl.dispose();
    _restCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final TranslationResult? result;

    if (widget.phrase != null) {
      result = _customResult;
    } else {
      final pipeline = ref.watch(pipelineProvider);
      result = pipeline.result;
    }

    // Initialize formal from settings default
    if (result != null && !_animationStarted) {
      _useFormal = settings?.formalDefault ?? false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startRevealAnimation(context);
      });
    }

    final targetPhrase =
        _useFormal ? (result?.germanFormal ?? '') : (result?.germanInformal ?? '');

    final pipeline = widget.phrase != null ? null : ref.watch(pipelineProvider);
    final isLoading = pipeline?.isLoading ?? false;
    final isError = pipeline?.stage == PipelineStage.error;
    final stageLabel = pipeline?.stageLabel ?? '';

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () {
            if (widget.phrase == null) {
              ref.read(pipelineProvider.notifier).reset();
            }
            Navigator.of(context).pop();
          },
        ),
        title: isLoading
            ? StageLabel(label: stageLabel)
            : null,
      ),
      body: isError
          ? _buildError(pipeline!)
          : result == null
              ? _buildLoading(pipeline!)
              : _buildResult(context, result, targetPhrase),
    );
  }

  Widget _buildLoading(PipelineState pipeline) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StageLabel(label: pipeline.stageLabel),
        ],
      ),
    );
  }

  Widget _buildError(PipelineState pipeline) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.brick, size: 40),
          const SizedBox(height: 16),
          Text(
            pipeline.errorMessage ?? 'Something went wrong.',
            style: AppTextStyles.body(size: 15, color: AppColors.brick),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.cobalt,
              side: const BorderSide(color: AppColors.cobalt),
            ),
            child: Text('Go back', style: AppTextStyles.bodyMedium(size: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(
      BuildContext context, TranslationResult result, String targetPhrase) {
    final hasGloss = result.wordGloss.isNotEmpty;
    final hasGrammar = result.grammarNote.isNotEmpty;
    final hasAlternate = result.alternatePhrasing.isNotEmpty;

    // Find gloss tile to highlight based on grammar note
    final highlightIdx = _findGrammarHighlightIndex(result);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── English Transcript ─────────────────────────────────────────
          FadeTransition(
            opacity: _transcriptOpacity,
            child: Text(
              result.englishText,
              style: AppTextStyles.transcript(size: 15),
            ),
          ),

          const SizedBox(height: 24),

          // ── German Phrase + Formal Toggle ─────────────────────────────
          SlideTransition(
            position: _phraseSlide,
            child: FadeTransition(
              opacity: _phraseOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          targetPhrase,
                          style: AppTextStyles.germanPhrase(size: 30),
                        ),
                      ),
                      if (result.germanFormal.isNotEmpty &&
                          result.germanFormal != result.germanInformal)
                        _buildFormalToggle(),
                    ],
                  ),
                  // Cobalt underline that draws from left to right
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: _underlineWidth,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _underlineWidth.value,
                          child: Container(
                            height: 2,
                            color: AppColors.cobalt,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Gloss Strip ────────────────────────────────────────────────
          if (hasGloss)
            GlossStrip(
              glossItems: result.wordGloss,
              highlightIndex: highlightIdx,
              animate: true,
              startAnimationDelayMs: 650,
              showPlay: true,
              showRuleMarkers: true,
            ),

          if (hasGloss) const SizedBox(height: 24),

          // ── Grammar Note ───────────────────────────────────────────────
          FadeTransition(
            opacity: _restOpacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasGrammar) ...[
                  _buildGrammarNote(result.grammarNote),
                  const SizedBox(height: 20),
                ],

                // ── Alternate Phrasing ────────────────────────────────
                if (hasAlternate) ...[
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body(size: 14, color: AppColors.inkMuted),
                      children: [
                        const TextSpan(text: 'Or you could say:  '),
                        TextSpan(
                          text: result.alternatePhrasing,
                          style: AppTextStyles.body(
                              size: 14, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const HairlineDivider(),
                const SizedBox(height: 20),

                // ── Playback Buttons ──────────────────────────────────
                Row(
                  children: [
                    PillButton(
                      label: 'Play',
                      icon: Icons.play_arrow_rounded,
                      onTap: () => ref
                          .read(pipelineProvider.notifier)
                          .playResult(germanText: targetPhrase),
                    ),
                    const SizedBox(width: 12),
                    PillButton(
                      label: 'Play slowly',
                      icon: Icons.slow_motion_video_rounded,
                      onTap: () => ref
                          .read(pipelineProvider.notifier)
                          .playResult(germanText: targetPhrase, speed: 0.5),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Actions ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  PracticeScreen(result: result),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cobalt,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: Text(
                          'Practice this',
                          style: AppTextStyles.bodyMedium(
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _SaveButton(result: result, saved: _saved, onSaved: () {
                      setState(() => _saved = true);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormalToggle() {
    return GestureDetector(
      onTap: () => setState(() => _useFormal = !_useFormal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _useFormal ? 'formal' : 'informal',
          style: AppTextStyles.label(size: 12, color: AppColors.cobalt),
        ),
      ),
    );
  }

  Widget _buildGrammarNote(String note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mustard.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.mustard.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.mustard, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(note, style: AppTextStyles.grammarNote()),
          ),
        ],
      ),
    );
  }

  /// Heuristic: find which gloss word the grammar note is referencing.
  int? _findGrammarHighlightIndex(TranslationResult result) {
    if (result.grammarNote.isEmpty || result.wordGloss.isEmpty) return null;
    final noteLower = result.grammarNote.toLowerCase();
    for (int i = 0; i < result.wordGloss.length; i++) {
      final gloss = result.wordGloss[i];
      if (noteLower.contains(gloss.de.toLowerCase()) ||
          noteLower.contains(gloss.en.toLowerCase())) {
        return i;
      }
    }
    return null;
  }
}

class _SaveButton extends ConsumerWidget {
  final TranslationResult result;
  final bool saved;
  final VoidCallback onSaved;

  const _SaveButton({
    required this.result,
    required this.saved,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: saved ? null : () => _save(context, ref),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: saved
            ? Row(
                key: const ValueKey('saved'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, size: 16, color: AppColors.teal),
                  const SizedBox(width: 4),
                  Text('Saved',
                      style: AppTextStyles.bodyMedium(
                          size: 15, color: AppColors.teal)),
                ],
              )
            : Text(
                'Save',
                key: const ValueKey('save'),
                style: AppTextStyles.bodyMedium(size: 15, color: AppColors.ink),
              ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    await ref.read(phrasebookProvider.notifier).savePhrase(result);
    onSaved();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phrase saved to your phrasebook.')),
      );
    }
  }
}
