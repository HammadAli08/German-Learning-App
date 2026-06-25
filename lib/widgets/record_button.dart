import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Circular record button with a calm pulsing cobalt ring while recording,
/// and a loading progress spinner while processing.
class RecordButton extends StatefulWidget {
  final bool isRecording;
  final bool isLoading;
  final VoidCallback? onTap;
  final double size;

  const RecordButton({
    super.key,
    required this.isRecording,
    this.isLoading = false,
    this.onTap,
    this.size = 80,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      final reducedMotion = MediaQuery.of(context).disableAnimations;
      if (!reducedMotion) _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = widget.isLoading;

    return GestureDetector(
      onTap: showLoading ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return SizedBox(
            width: widget.size + 48,
            height: widget.size + 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulsing ring
                if (widget.isRecording)
                  Opacity(
                    opacity: (1.0 - _pulseAnim.value) * 0.5,
                    child: Container(
                      width: widget.size + 32 + (_pulseAnim.value * 16),
                      height: widget.size + 32 + (_pulseAnim.value * 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cobalt,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                // Inner static ring
                if (widget.isRecording)
                  Container(
                    width: widget.size + 16,
                    height: widget.size + 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cobalt.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                // Button face
                child!,
              ],
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: showLoading
                ? AppColors.inkMuted
                : widget.isRecording
                    ? AppColors.brick
                    : AppColors.cobalt,
          ),
          child: Center(
            child: showLoading
                ? SizedBox(
                    width: widget.size * 0.35,
                    height: widget.size * 0.35,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: widget.size * 0.4,
                  ),
          ),
        ),
      ),
    );
  }
}
