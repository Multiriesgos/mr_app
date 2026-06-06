import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAvailability { available, notAvailable, notEnrolled }

class BiometricsService {
  BiometricsService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricAvailability> checkAvailability() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return BiometricAvailability.notAvailable;
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return BiometricAvailability.notAvailable;
      final available = await _auth.getAvailableBiometrics();
      return available.isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on PlatformException {
      return BiometricAvailability.notAvailable;
    }
  }

  Future<bool> authenticate({String reason = 'Verifica tu identidad'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}

final biometricsServiceProvider = Provider<BiometricsService>(
  (_) => BiometricsService(),
);
