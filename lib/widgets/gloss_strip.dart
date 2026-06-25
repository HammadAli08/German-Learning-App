import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/word_gloss.dart';

/// The signature element: a horizontal row of gloss tiles, one per German word.
/// Each tile shows the German word on top and its English meaning below.
/// The tile whose index matches [highlightIndex] gets a mustard border.
class GlossStrip extends StatelessWidget {
  final List<WordGloss> glossItems;
  /// Index of the word that the grammar note references (gets mustard border).
  final int? highlightIndex;
  final bool animate;
  final int startAnimationDelayMs;

  const GlossStrip({
    super.key,
    required this.glossItems,
    this.highlightIndex,
    this.animate = false,
    this.startAnimationDelayMs = 0,
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
              )
            else
              GlossTile(
                item: glossItems[i],
                isHighlighted: highlightIndex == i,
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

  const GlossTile({super.key, required this.item, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppColors.mustard.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border.all(
          color: isHighlighted ? AppColors.mustard : AppColors.inkMuted.withValues(alpha: 0.35),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item.de, style: AppTextStyles.glossDe()),
          const SizedBox(height: 2),
          Text(item.en, style: AppTextStyles.glossEn()),
        ],
      ),
    );
  }
}

class _AnimatedGlossTile extends StatefulWidget {
  final WordGloss item;
  final bool isHighlighted;
  final int delayMs;

  const _AnimatedGlossTile({
    required this.item,
    required this.isHighlighted,
    required this.delayMs,
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
        child: GlossTile(item: widget.item, isHighlighted: widget.isHighlighted),
      ),
    );
  }
}
