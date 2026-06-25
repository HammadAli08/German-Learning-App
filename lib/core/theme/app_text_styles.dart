import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// GermanLoop typography system.
/// Space Grotesk: screen titles, German phrase
/// IBM Plex Sans: body, English text, grammar notes, UI labels
/// IBM Plex Mono: word gloss strip, literal annotations
abstract class AppTextStyles {
  // ── Space Grotesk ────────────────────────────────────────────────────────
  /// German phrase — the most prominent text element in the app. ≥28px.
  static TextStyle germanPhrase({double size = 30}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.25,
      );

  /// Screen titles and section headers.
  static TextStyle screenTitle({double size = 20}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
        height: 1.3,
      );

  /// Score display and large numeric values.
  static TextStyle scoreDisplay({double size = 36}) => GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      );

  // ── IBM Plex Sans ─────────────────────────────────────────────────────────
  /// Standard body text.
  static TextStyle body({double size = 15, Color? color}) => GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.ink,
        height: 1.5,
      );

  /// Medium weight body — used for labels, section names.
  static TextStyle bodyMedium({double size = 15, Color? color}) => GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.ink,
      );

  /// English transcript and secondary prose.
  static TextStyle transcript({double size = 15}) => GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: AppColors.inkMuted,
        height: 1.5,
      );

  /// Grammar note text inside mustard callout.
  static TextStyle grammarNote({double size = 14}) => GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.5,
      );

  /// UI labels — settings rows, captions.
  static TextStyle label({double size = 13, Color? color}) => GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.inkMuted,
      );

  // ── IBM Plex Mono ─────────────────────────────────────────────────────────
  /// Gloss strip — German word label on each tile.
  static TextStyle glossDe({double size = 13}) => GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
      );

  /// Gloss strip — English meaning below each German word.
  static TextStyle glossEn({double size = 11}) => GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: AppColors.inkMuted,
      );

  /// Practice screen — matched/mismatched word annotation.
  static TextStyle practiceWord({double size = 15, Color? color}) => GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.ink,
      );
}
