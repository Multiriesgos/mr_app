import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:mr_app/core/auth/biometrics_service.dart';

class _FakeLocalAuthPlatform extends LocalAuthPlatform {
  bool isDeviceSupportedResult = true;
  bool canCheckBiometricsResult = true;
  List<BiometricType> enrolledBiometrics = const [BiometricType.fingerprint];

  bool authenticateResult = true;
  Exception? throwOnAuthenticate;
  Exception? throwOnCheckAvailability;

  @override
  Future<bool> isDeviceSupported() async {
    if (throwOnCheckAvailability != null) throw throwOnCheckAvailability!;
    return isDeviceSupportedResult;
  }

  @override
  Future<bool> deviceSupportsBiometrics() async {
    if (throwOnCheckAvailability != null) throw throwOnCheckAvailability!;
    return canCheckBiometricsResult;
  }

  @override
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    if (throwOnCheckAvailability != null) throw throwOnCheckAvailability!;
    return enrolledBiometrics;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    if (throwOnAuthenticate != null) throw throwOnAuthenticate!;
    return authenticateResult;
  }
}

void main() {
  late _FakeLocalAuthPlatform fakePlatform;
  late BiometricsService service;

  setUp(() {
    fakePlatform = _FakeLocalAuthPlatform();
    LocalAuthPlatform.instance = fakePlatform;
    service = BiometricsService();
  });

  group('checkAvailability', () {
    test('devuelve available cuando hay soporte y biometría enrolada', () async {
      fakePlatform
        ..isDeviceSupportedResult = true
        ..canCheckBiometricsResult = true
        ..enrolledBiometrics = const [BiometricType.fingerprint];

      final result = await service.checkAvailability();

      expect(result, BiometricAvailability.available);
    });

    test('devuelve notEnrolled cuando hay soporte pero nada enrolado', () async {
      fakePlatform
        ..isDeviceSupportedResult = true
        ..canCheckBiometricsResult = true
        ..enrolledBiometrics = const [];

      final result = await service.checkAvailability();

      expect(result, BiometricAvailability.notEnrolled);
    });

    test('devuelve notAvailable cuando el dispositivo no es soportado', () async {
      fakePlatform.isDeviceSupportedResult = false;

      final result = await service.checkAvailability();

      expect(result, BiometricAvailability.notAvailable);
    });

    test('devuelve notAvailable cuando canCheckBiometrics es false', () async {
      fakePlatform
        ..isDeviceSupportedResult = true
        ..canCheckBiometricsResult = false;

      final result = await service.checkAvailability();

      expect(result, BiometricAvailability.notAvailable);
    });

    test('devuelve notAvailable cuando el plugin lanza LocalAuthException', () async {
      fakePlatform.throwOnCheckAvailability = const LocalAuthException(
        code: LocalAuthExceptionCode.noBiometricHardware,
      );

      final result = await service.checkAvailability();

      expect(result, BiometricAvailability.notAvailable);
    });
  });

  group('authenticate', () {
    test('devuelve true cuando la autenticación es exitosa', () async {
      fakePlatform.authenticateResult = true;

      final result = await service.authenticate();

      expect(result, isTrue);
    });

    test('devuelve false cuando la autenticación falla sin excepción', () async {
      fakePlatform.authenticateResult = false;

      final result = await service.authenticate();

      expect(result, isFalse);
    });

    test('devuelve false cuando el plugin lanza LocalAuthException (ej. cancelado)',
        () async {
      fakePlatform.throwOnAuthenticate = const LocalAuthException(
        code: LocalAuthExceptionCode.userCanceled,
      );

      final result = await service.authenticate();

      expect(result, isFalse);
    });
  });
}
