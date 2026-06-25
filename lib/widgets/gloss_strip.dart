import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/word_gloss.dart';
import '../data/pronunciation_rules.dart';
import 'word_play_button.dart';

/// The signature element: a horizontal row of gloss tiles, one per German word.
/// Each tile shows the German word on top and its English meaning below.
/// The tile whose index matches [highlightIndex] gets a mustard border.
/// If [showPlay] is true, each tile gets a small play icon.
/// If [showRuleMarkers] is true, words matching pronunciation rules show a marker.
class GlossStrip extends StatelessWidget {
  final List<WordGloss> glossItems;

  /// Index of the word that the grammar note references (gets mustard border).
  final int? highlightIndex;
  final bool animate;
  final int startAnimationDelayMs;
  final bool showPlay;
  final bool showRuleMarkers;

  const GlossStrip({
    super.key,
    required this.glossItems,
    this.highlightIndex,
    this.animate = false,
    this.startAnimationDelayMs = 0,
    this.showPlay = false,
    this.showRuleMarkers = false,
  });

  @override
  Widget build(BuildContext context) {
    if (glossItems.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < glossItems.length; i++) ...[
            if (animate)
              _AnimatedGlossTile(
                item: glossItems[i],
                isHighlighted: highlightIndex == i,
                delayMs: startAnimationDelayMs + (i * 60),
                showPlay: showPlay,
                showRuleMarkers: showRuleMarkers,
              )
            else
              GlossTile(
                item: glossItems[i],
                isHighlighted: highlightIndex == i,
                showPlay: showPlay,
                showRuleMarkers: showRuleMarkers,
              ),
            if (i < glossItems.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Individual gloss tile: German word over English meaning.
class GlossTile extends StatelessWidget {
  final WordGloss item;
  final bool isHighlighted;
  final bool showPlay;
  final bool showRuleMarkers;

  const GlossTile({
    super.key,
    required this.item,
    this.isHighlighted = false,
    this.showPlay = false,
    this.showRuleMarkers = false,
  });

  @override
  Widget build(BuildContext context) {
    final rules = showRuleMarkers ? matchingRules(item.de) : <PronunciationRule>[];

    return GestureDetector(
      onTap: rules.isEmpty || !showRuleMarkers
          ? null
          : () => _showRules(context, rules),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.mustard.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: isHighlighted
                ? AppColors.mustard
                : AppColors.inkMuted.withValues(alpha: 0.35),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // German word row with optional play button and rule marker
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.de, style: AppTextStyles.glossDe()),
                if (showRuleMarkers && rules.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.mustard,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                if (showPlay) ...[
                  const SizedBox(width: 4),
                  WordPlayButton(word: item.de, size: 14),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(item.en, style: AppTextStyles.glossEn()),
          ],
        ),
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
      builder: (_) => _RulesSheet(word: item.de, rules: rules),
    );
  }
}

class _RulesSheet extends StatelessWidget {
  final String word;
  final List<PronunciationRule> rules;

  const _RulesSheet({required this.word, required this.rules});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.mustard,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Pronunciation in "$word"',
                  style: AppTextStyles.bodyMedium(size: 15)),
            ],
          ),
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
                        style: AppTextStyles.body(size: 13,
                            color: AppColors.inkMuted)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _AnimatedGlossTile extends StatefulWidget {
  final WordGloss item;
  final bool isHighlighted;
  final int delayMs;
  final bool showPlay;
  final bool showRuleMarkers;

  const _AnimatedGlossTile({
    required this.item,
    required this.isHighlighted,
    required this.delayMs,
    required this.showPlay,
    required this.showRuleMarkers,
  });

  @override
  State<_AnimatedGlossTile> createState() => _AnimatedGlossTileState();
}

class _AnimatedGlossTileState extends State<_AnimatedGlossTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion) {
      _ctrl.value = 1.0;
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: GlossTile(
          item: widget.item,
          isHighlighted: widget.isHighlighted,
          showPlay: widget.showPlay,
          showRuleMarkers: widget.showRuleMarkers,
        ),
      ),
    );
  }
}
