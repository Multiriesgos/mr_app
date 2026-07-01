import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mr_app/core/error/app_exception.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mr_app/features/auth/presentation/providers/auth_notifier.dart';

const _tUser = User(
  documentNumber: '12345678',
  name: 'Juan Pérez',
  email: 'juan@example.com',
  docSearch: 'ABC123',
);

class _FakeAuthRepository implements AuthRepository {
  User? savedUser;
  String? savedDocumentNumber;
  String? savedBirthDate;
  bool savedRememberMe = false;

  Exception? throwOnLogin;
  User? loginResult;

  int loginCalls = 0;
  int logoutCalls = 0;
  String? lastLoginDocumentNumber;
  String? lastLoginBirthDate;
  bool? lastLoginRememberMe;

  @override
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async {
    loginCalls++;
    lastLoginDocumentNumber = documentNumber;
    lastLoginBirthDate = birthDate;
    lastLoginRememberMe = rememberMe;
    if (throwOnLogin != null) throw throwOnLogin!;
    return loginResult ?? _tUser;
  }

  @override
  Future<User?> getSavedUser() async => savedUser;

  @override
  Future<String?> getSavedDocumentNumber() async => savedDocumentNumber;

  @override
  Future<String?> getSavedBirthDate() async => savedBirthDate;

  @override
  Future<bool> getSavedRememberMe() async => savedRememberMe;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

void main() {
  late _FakeAuthRepository repo;

  ProviderContainer buildContainer() {
    repo = _FakeAuthRepository();
    return ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
  }

  group('build', () {
    test('devuelve AuthAuthenticated cuando hay un usuario guardado', () async {
      final container = buildContainer();
      repo.savedUser = _tUser;

      final state = await container.read(authProvider.future);

      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user, _tUser);
    });

    test('devuelve AuthUnauthenticated cuando no hay usuario guardado', () async {
      final container = buildContainer();
      repo.savedUser = null;

      final state = await container.read(authProvider.future);

      expect(state, isA<AuthUnauthenticated>());
    });
  });

  group('login', () {
    test('actualiza el estado a AuthAuthenticated con el usuario del repositorio',
        () async {
      final container = buildContainer();
      repo.savedUser = null;
      await container.read(authProvider.future);
      repo.loginResult = _tUser;

      await container.read(authProvider.notifier).login(
            documentNumber: '12345678',
            birthDate: '01/01/1990',
            rememberMe: true,
          );

      final state = container.read(authProvider);
      expect(state.value, isA<AuthAuthenticated>());
      expect((state.value! as AuthAuthenticated).user, _tUser);
      expect(repo.loginCalls, 1);
      expect(repo.lastLoginDocumentNumber, '12345678');
      expect(repo.lastLoginBirthDate, '01/01/1990');
      expect(repo.lastLoginRememberMe, isTrue);
    });

    test('propaga la excepción del repositorio sin cambiar el estado a autenticado',
        () async {
      final container = buildContainer();
      repo.savedUser = null;
      await container.read(authProvider.future);
      repo.throwOnLogin = const AuthException('Credenciales inválidas');

      await expectLater(
        () => container.read(authProvider.notifier).login(
              documentNumber: '12345678',
              birthDate: 'fecha-incorrecta',
              rememberMe: true,
            ),
        throwsA(isA<AuthException>()),
      );

      final state = container.read(authProvider);
      expect(state.value, isA<AuthUnauthenticated>());
    });
  });

  group('logout', () {
    test('pasa por AsyncLoading y termina en AuthUnauthenticated', () async {
      final container = buildContainer();
      repo.savedUser = _tUser;
      await container.read(authProvider.future);
      expect(
        container.read(authProvider).value,
        isA<AuthAuthenticated>(),
      );

      await container.read(authProvider.notifier).logout();

      expect(repo.logoutCalls, 1);
      expect(container.read(authProvider).value, isA<AuthUnauthenticated>());
    });
  });

  group('getters delegados', () {
    test('getSavedDocumentNumber delega en el repositorio', () async {
      final container = buildContainer();
      repo.savedUser = null;
      await container.read(authProvider.future);
      repo.savedDocumentNumber = '12345678';

      expect(
        await container.read(authProvider.notifier).getSavedDocumentNumber(),
        '12345678',
      );
    });

    test('getSavedBirthDate delega en el repositorio', () async {
      final container = buildContainer();
      repo.savedUser = null;
      await container.read(authProvider.future);
      repo.savedBirthDate = '01/01/1990';

      expect(
        await container.read(authProvider.notifier).getSavedBirthDate(),
        '01/01/1990',
      );
    });
  });
}
