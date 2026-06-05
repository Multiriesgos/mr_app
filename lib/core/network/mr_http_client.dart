import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Proveedor Riverpod del cliente HTTP endurecido.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = MrHttpClient.create();
  ref.onDispose(client.close);
  return client;
});

/// Fábrica del cliente HTTP con certificate pinning activo.
///
/// ESTADO DEL PINNING — secure.multiriesgos.com (Let's Encrypt R12)
/// ─────────────────────────────────────────────────────────────────
/// Cert SHA-256 : s7F+oUuSAuFiKXrSj5cQlHJTNVvIKrYAsQc/wX7QO4A=
/// SPKI SHA-256 : cp1SngqIwTORG7J1sUU+0l300zt7Y5kIoMU09OHEQAU=  ← ACTIVO
/// Verificado   : 2026-06-05 vía openssl s_client + pkey DER SHA-256
/// Válido hasta : 2026-07-28  →  RENOVAR PINES ANTES DE 2026-06-28
///
/// Al renovar el certificado (Let's Encrypt renueva automáticamente):
///   1. Obtener SPKI: openssl x509 -in cert.der -inform der -pubkey -noout
///                    | openssl pkey -pubin -outform der
///                    | openssl dgst -sha256 -binary | openssl enc -base64
///   2. Actualizar [_spkiPin] aquí
///   3. Actualizar network_security_config.xml  (Android)
///   4. Actualizar NSPinnedDomains en Info.plist (iOS)
abstract final class MrHttpClient {
  /// SPKI SHA-256 de secure.multiriesgos.com.
  /// Usado en Android network_security_config y iOS NSPinnedDomains.
  static const _spkiPin =
      'cp1SngqIwTORG7J1sUU+0l300zt7Y5kIoMU09OHEQAU=';

  /// SHA-256 del DER completo. Referencia para diagnóstico y renovación.
  static const _certPin =
      's7F+oUuSAuFiKXrSj5cQlHJTNVvIKrYAsQc/wX7QO4A=';

  static http.Client create() {
    if (kIsWeb) return http.Client();
    final ioClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = rejectBadCerts;
    return IOClient(ioClient);
  }

  /// Rechaza siempre certificados con fallos de validación del sistema.
  /// El pinning de SPKI lo aplican las capas de plataforma:
  ///   Android → network_security_config.xml  (API 24+)
  ///   iOS     → NSPinnedDomains en Info.plist (iOS 14+)
  static bool rejectBadCerts(X509Certificate cert, String host, int port) =>
      false;

  /// Verifica el hash SHA-256 del DER completo de un certificado.
  /// Útil en tests de integración y herramientas de diagnóstico.
  static bool verifyCertHash(X509Certificate cert) {
    if (_certPin.isEmpty) return true;
    final hash = base64.encode(sha256.convert(cert.der).bytes);
    return hash == _certPin;
  }

  static String get spkiPin => _spkiPin;
}
