import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Logger singleton. Usa [appLogger] en todo el código.
///
/// Niveles:
///   appLogger.debug   — solo en debug builds
///   appLogger.info    — eventos de negocio
///   appLogger.warning — recuperable pero anómalo
///   appLogger.error   — error que va a Crashlytics
///
/// NUNCA pasar PII: documentNumber, birthDate, email.
final Talker appLogger = Talker(
  settings: TalkerSettings(
    enabled: true,
    useConsoleLogs: kDebugMode,
  ),
  observer: _CrashlyticsObserver(),
);

/// Reenvía los errores de Talker a Firebase Crashlytics (solo en release).
class _CrashlyticsObserver extends TalkerObserver {
  @override
  void onError(TalkerError err) {
    if (kDebugMode) return;
    FirebaseCrashlytics.instance.recordError(
      err.error,
      err.stackTrace,
      reason: err.message,
    );
  }

  @override
  void onException(TalkerException err) {
    if (kDebugMode) return;
    FirebaseCrashlytics.instance.recordError(
      err.exception,
      err.stackTrace,
      reason: err.message,
    );
  }
}
