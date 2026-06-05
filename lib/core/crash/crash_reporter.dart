import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReporterProvider = Provider<CrashReporter>(
  (_) => CrashReporter._(),
);

/// Wrapper sobre Firebase Crashlytics.
/// Centraliza el reporte de errores y la identificación de usuario.
class CrashReporter {
  CrashReporter._();

  FirebaseCrashlytics get _c => FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    // En debug no enviar crashes a Crashlytics (evita ruido).
    await _c.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  /// Identificar al usuario con un hash del número de documento.
  /// Nunca enviar el documento en texto plano (PII).
  Future<void> setUserIdentifier(String docNumberHash) async {
    await _c.setUserIdentifier(docNumberHash);
  }

  Future<void> clearUserIdentifier() async {
    await _c.setUserIdentifier('');
  }

  /// Reportar un error no fatal (registrado en Crashlytics pero no marca
  /// la sesión como crash).
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _c.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Registrar un evento informativo (breadcrumb).
  Future<void> log(String message) async {
    await _c.log(message);
  }
}
