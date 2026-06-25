import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Animated label that cross-fades between pipeline stage strings.
/// Shows: "Transcribing" → "Translating" → "Generating audio"
class StageLabel extends StatefulWidget {
  final String label;

  const StageLabel({super.key, required this.label});

  @override
  State<StageLabel> createState() => _StageLabelState();
}

class _StageLabelState extends State<StageLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  String _displayedLabel = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _displayedLabel = widget.label;
    if (widget.label.isNotEmpty) _ctrl.forward();
  }

  @override
  void didUpdateWidget(StageLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label != oldWidget.label) {
      if (widget.label.isEmpty) {
        _ctrl.reverse();
      } else {
        _ctrl.reverse().then((_) {
          if (mounted) {
            setState(() => _displayedLabel = widget.label);
            _ctrl.forward();
          }
        });
      }
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.cobalt,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _displayedLabel,
            style: AppTextStyles.label(size: 13, color: AppColors.cobalt),
          ),
        ],
      ),
    );
  }
}
