import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mr_app/features/auth/domain/usecases/login_usecase.dart';

// Fake repository para aislar el use case del almacenamiento real
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.result});
  final Object result; // User o AppException

  @override
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async {
    if (result is Exception) throw result as Exception;
    return result as User;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<User?> getSavedUser() async => null;

  @override
  Future<String?> getSavedDocumentNumber() async => null;

  @override
  Future<String?> getSavedBirthDate() async => null;

  @override
  Future<bool> getSavedRememberMe() async => false;
}

void main() {
  const tUser = User(
    documentNumber: '12345678',
    name: 'Juan Pérez',
    email: 'juan@example.com',
    docSearch: '12345678',
  );

  group('LoginUseCase', () {
    test('devuelve User cuando las credenciales son correctas', () async {
      final sut = LoginUseCase(_FakeAuthRepository(result: tUser));

      final result = await sut(
        documentNumber: '12345678',
        birthDate: '01/01/1990',
        rememberMe: true,
      );

      expect(result, equals(tUser));
    });

    test('propaga AuthException cuando las credenciales son inválidas',
        () async {
      final sut =
          LoginUseCase(_FakeAuthRepository(result: const AuthException()));

      await expectLater(
        () => sut(
          documentNumber: '12345678',
          birthDate: '99/99/9999',
          rememberMe: false,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('propaga NetworkException cuando hay error de red', () async {
      final sut =
          LoginUseCase(_FakeAuthRepository(result: const NetworkException()));

      await expectLater(
        () => sut(
          documentNumber: '12345678',
          birthDate: '01/01/1990',
          rememberMe: true,
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
