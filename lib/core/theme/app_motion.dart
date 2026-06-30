/// IBM Carbon Design System v11 — Motion Tokens
/// https://carbondesignsystem.com/elements/motion/overview/
///
/// Use durations + curves together:
///   AnimationController(duration: AppMotion.moderate01)
///   CurvedAnimation(curve: AppMotion.entrance)
library;

import 'package:flutter/animation.dart';

abstract final class AppMotion {
  // ─── Durations ────────────────────────────────────────────────────────────
  /// 70 ms — micro-interactions (focus rings, toggles, checkboxes)
  static const Duration fast01 = Duration(milliseconds: 70);

  /// 110 ms — small UI elements entering/exiting (tooltips, dropdowns)
  static const Duration fast02 = Duration(milliseconds: 110);

  /// 150 ms — medium UI elements (popovers, inline notifications)
  static const Duration moderate01 = Duration(milliseconds: 150);

  /// 240 ms — navigation, expansion panels, modals
  static const Duration moderate02 = Duration(milliseconds: 240);

  /// 400 ms — large element transitions (page sections, skeletons)
  static const Duration slow01 = Duration(milliseconds: 400);

  /// 500 ms — full-page transitions, onboarding
  static const Duration slow02 = Duration(milliseconds: 500);

  // ─── Easing curves (Carbon cubic-bezier) ──────────────────────────────────
  /// Entrance: elements entering the screen (ease-out feel)
  static const Curve entrance = Cubic(0, 0, 0.38, 0.9);

  /// Exit: elements leaving the screen (ease-in feel)
  static const Curve exit = Cubic(0.2, 0, 1, 0.9);

  /// Standard: elements that stay on screen but transform
  static const Curve standard = Cubic(0.2, 0, 0.38, 0.9);

  /// Expressive entrance: hero elements, onboarding (overshoot feel)
  static const Curve expressiveEntrance = Cubic(0, 0, 0.3, 1);

  /// Expressive standard: modals, drawers, sidebars
  static const Curve expressiveStandard = Cubic(0.4, 0.14, 0.3, 1);

  // ─── iOS-inspired spring curve ────────────────────────────────────────────
  /// Overshoot suave — botones, cards, hero transitions
  static const Curve spring = Cubic(0.34, 1.20, 0.64, 1);

  /// Bounce ligero — para scale press feedback
  static const Curve springBounce = Cubic(0.22, 1.40, 0.36, 1);

  // ─── Duraciones adicionales ───────────────────────────────────────────────
  /// 80 ms — press scale down feedback
  static const Duration press = Duration(milliseconds: 80);

  /// 350 ms — hero / shared element transitions
  static const Duration hero = Duration(milliseconds: 350);

  /// 600 ms — onboarding / splash entry
  static const Duration intro = Duration(milliseconds: 600);
}
