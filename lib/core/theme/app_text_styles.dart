/// IBM Carbon Design System v11 — Productive Type Scale
/// https://carbondesignsystem.com/elements/typography/type-sets/
///
/// Defines size, weight, line-height and letter-spacing only.
/// Font family (IBM Plex Sans) is inherited from ThemeData.fontFamily.
/// Apply color at call site: AppTextStyles.label01.copyWith(color: ...).
library;

import 'package:flutter/painting.dart';

abstract final class AppTextStyles {
  // ─── Label ───────────────────────────────────────────────────────────────
  /// 12px / Regular / lh 16 / ls 0.32 — form labels, metadata
  static const TextStyle label01 = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.333, letterSpacing: 0.32,
  );

  /// 14px / Regular / lh 18 / ls 0.16 — secondary labels
  static const TextStyle label02 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.286, letterSpacing: 0.16,
  );

  // ─── Helper text ──────────────────────────────────────────────────────────
  /// 12px / Regular / italic / lh 16 / ls 0.32 — form hints, captions
  static const TextStyle helperText01 = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.333, letterSpacing: 0.32,
    fontStyle: FontStyle.italic,
  );

  // ─── Body compact (dense UI, single-line) ─────────────────────────────────
  /// 14px / Regular / lh 18 / ls 0.16 — list rows, table cells
  static const TextStyle bodyCompact01 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.286, letterSpacing: 0.16,
  );

  /// 16px / Regular / lh 22 — larger body in compact context
  static const TextStyle bodyCompact02 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.375,
  );

  // ─── Body (multi-line prose) ───────────────────────────────────────────────
  /// 14px / Regular / lh 20 / ls 0.16 — paragraphs, descriptions
  static const TextStyle body01 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.429, letterSpacing: 0.16,
  );

  /// 16px / Regular / lh 24 — larger prose blocks
  static const TextStyle body02 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.500,
  );

  // ─── Heading compact ──────────────────────────────────────────────────────
  /// 14px / SemiBold / lh 18 / ls 0.16 — card titles, section labels
  static const TextStyle headingCompact01 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.286, letterSpacing: 0.16,
  );

  /// 16px / SemiBold / lh 22 — sub-section headings
  static const TextStyle headingCompact02 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.375,
  );

  // ─── Heading (multiline-safe) ─────────────────────────────────────────────
  /// 14px / SemiBold / lh 20 / ls 0.16
  static const TextStyle heading01 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.429, letterSpacing: 0.16,
  );

  /// 16px / SemiBold / lh 24
  static const TextStyle heading02 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.500,
  );

  /// 20px / Regular / lh 28 — page section headings
  static const TextStyle heading03 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w400, height: 1.400,
  );

  /// 28px / Regular / lh 36 — screen-level headings
  static const TextStyle heading04 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w400, height: 1.286,
  );

  /// 36px / Regular / lh 44 — hero headings
  static const TextStyle heading05 = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w400, height: 1.222,
  );

  /// 48px / Light / lh 56 — display / splash
  static const TextStyle heading06 = TextStyle(
    fontSize: 48, fontWeight: FontWeight.w300, height: 1.167,
  );

  // ─── Productive headings (concise SemiBold variants) ─────────────────────
  /// 12px / SemiBold / lh 16 / ls 0.32 — overline labels, section caps
  static const TextStyle productiveHeading01 = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, height: 1.333, letterSpacing: 0.32,
  );

  /// 14px / SemiBold / lh 20 / ls 0.16 — modal titles, list section headers
  static const TextStyle productiveHeading02 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.429, letterSpacing: 0.16,
  );

  /// 20px / Regular / lh 28 — dialog headings
  static const TextStyle productiveHeading03 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w400, height: 1.400,
  );

  /// 28px / Regular / lh 36 — page-level headings
  static const TextStyle productiveHeading04 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w400, height: 1.286,
  );

  // ─── Display (áreas hero) ─────────────────────────────────────────────────
  /// 40px / SemiBold / lh 48 — sumas de dinero, stats grandes
  static const TextStyle displayXs = TextStyle(
    fontSize: 40, fontWeight: FontWeight.w600, height: 1.2,
  );

  /// 32px / Regular / lh 40 — hero de pantalla
  static const TextStyle displaySm = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w400, height: 1.25,
  );

  // ─── Caption / overline ───────────────────────────────────────────────────
  /// 11px / Regular / lh 16 / ls 0.4 — metadata compacto
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.455, letterSpacing: 0.4,
  );

  /// 11px / SemiBold / lh 16 / ls 0.8 — etiquetas de sección en mayúsculas
  static const TextStyle overline = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600, height: 1.455, letterSpacing: 0.8,
  );
}
