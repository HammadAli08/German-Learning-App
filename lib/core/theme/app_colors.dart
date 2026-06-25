import 'package:flutter/material.dart';

/// GermanLoop Bauhaus design system — color palette.
/// Use ONLY these colors. Each accent has exactly one job.
abstract class AppColors {
  // Base
  static const Color paper = Color(0xFFEEEAE2);
  static const Color ink = Color(0xFF1B1B18);
  static const Color inkMuted = Color(0xFF6B6860);

  // Accents — each has exactly one semantic purpose
  static const Color cobalt = Color(0xFF1E5AA8); // primary actions, record btn, links, underlines
  static const Color mustard = Color(0xFFE8A33D); // grammar note callout, highlighted gloss word
  static const Color brick = Color(0xFFC73E3A);   // mismatch highlights, destructive actions
  static const Color teal = Color(0xFF2F7A5E);    // correct/matched feedback, saved state

  // Derived
  static const Color hairline = Color(0x336B6860); // inkMuted at ~20% opacity
  static const Color cobaltOutline = Color(0x331E5AA8); // cobalt at ~20% opacity for pulse ring
}
