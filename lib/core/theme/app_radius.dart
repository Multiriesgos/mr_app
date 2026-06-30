/// Design token: border radii
/// Escala progresiva: xs → pill.
/// Todos los widgets deben usar estos tokens en vez de valores hardcoded.
library;

import 'package:flutter/painting.dart';

abstract final class AppRadius {
  static const double xs   =  4;
  static const double sm   =  8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double pill = 100;

  // ── BorderRadius shortcuts ────────────────────────────────────────────────
  static BorderRadius get xsBR   => BorderRadius.circular(xs);
  static BorderRadius get smBR   => BorderRadius.circular(sm);
  static BorderRadius get mdBR   => BorderRadius.circular(md);
  static BorderRadius get lgBR   => BorderRadius.circular(lg);
  static BorderRadius get xlBR   => BorderRadius.circular(xl);
  static BorderRadius get xxlBR  => BorderRadius.circular(xxl);
  static BorderRadius get pillBR => BorderRadius.circular(pill);

  // ── Radius shortcuts ──────────────────────────────────────────────────────
  static Radius get xsR   => const Radius.circular(xs);
  static Radius get smR   => const Radius.circular(sm);
  static Radius get mdR   => const Radius.circular(md);
  static Radius get lgR   => const Radius.circular(lg);
  static Radius get xlR   => const Radius.circular(xl);

  // ── Top-only (bottom sheets) ──────────────────────────────────────────────
  static BorderRadius get topLg => const BorderRadius.only(
    topLeft: Radius.circular(lg), topRight: Radius.circular(lg),
  );
  static BorderRadius get topXl => const BorderRadius.only(
    topLeft: Radius.circular(xl), topRight: Radius.circular(xl),
  );
  static BorderRadius get topXxl => const BorderRadius.only(
    topLeft: Radius.circular(xxl), topRight: Radius.circular(xxl),
  );
}
