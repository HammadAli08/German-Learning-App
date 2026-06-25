import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A 1-pixel hairline divider in ink muted at low opacity.
/// Used instead of box shadows to separate sections throughout the app.
class HairlineDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const HairlineDivider({super.key, this.indent = 0, this.endIndent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: AppColors.hairline,
    );
  }
}
