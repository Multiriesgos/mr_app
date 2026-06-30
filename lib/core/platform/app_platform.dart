/// Detección de plataforma para Adaptive UI.
/// Usa `defaultTargetPlatform` (funciona en tests y en web).
library;

import 'package:flutter/foundation.dart';

abstract final class AppPlatform {
  static bool get isIOS     => defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  /// Alias semántico: "¿debo usar widgets Cupertino?"
  static bool get cupertino => isIOS;
}
