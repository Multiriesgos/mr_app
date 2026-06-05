import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mr_app/features/auth/domain/usecases/logout_usecase.dart';

class _TrackingRepository implements AuthRepository {
  bool logoutCalled = false;
  Exception? throwOnLogout;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (throwOnLogout != null) throw throwOnLogout!;
  }

  @override
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async =>
      throw UnimplementedError();

  @override
  Future<User?> getSavedUser() async => null;

  @override
  Future<String?> getSavedDocumentNumber() async => null;

  @override
  Future<bool> getSavedRememberMe() async => false;
}

void main() {
  group('LogoutUseCase', () {
    test('delega la llamada al repositorio', () async {
      final repo = _TrackingRepository();
      final sut = LogoutUseCase(repo);

      await sut();

      expect(repo.logoutCalled, isTrue);
    });

    test('propaga la excepción si el repositorio falla', () async {
      final repo = _TrackingRepository()
        ..throwOnLogout = Exception('storage error');
      final sut = LogoutUseCase(repo);

      await expectLater(() => sut(), throwsException);
    });
  });
}
