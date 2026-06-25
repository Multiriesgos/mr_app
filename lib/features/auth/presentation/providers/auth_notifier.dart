import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_app/core/network/mr_http_client.dart';
import 'package:mr_app/core/storage/secure_storage.dart';
import 'package:mr_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mr_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mr_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mr_app/features/auth/domain/usecases/get_saved_user_usecase.dart';
import 'package:mr_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:mr_app/features/auth/domain/usecases/logout_usecase.dart';

// ---------- DI providers ----------

final _authLocalDataSourceProvider =
    Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageProvider));
});

final _authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(client: ref.watch(httpClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(_authRemoteDataSourceProvider),
    local: ref.watch(_authLocalDataSourceProvider),
  );
});

// ---------- Auth state ----------

sealed class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// ---------- Notifier ----------

class AuthNotifier extends AsyncNotifier<AuthState> {
  late LoginUseCase _login;
  late LogoutUseCase _logout;
  late GetSavedUserUseCase _getSaved;

  @override
  Future<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);
    _login = LoginUseCase(repo);
    _logout = LogoutUseCase(repo);
    _getSaved = GetSavedUserUseCase(repo);

    final saved = await _getSaved();
    return saved != null
        ? AuthAuthenticated(saved)
        : const AuthUnauthenticated();
  }

  Future<void> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _login(
        documentNumber: documentNumber,
        birthDate: birthDate,
        rememberMe: rememberMe,
      );
      return AuthAuthenticated(user);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await _logout();
    state = const AsyncData(AuthUnauthenticated());
  }

  /// Devuelve el número de documento guardado (para pre-llenar el form de login).
  Future<String?> getSavedDocumentNumber() =>
      ref.read(authRepositoryProvider).getSavedDocumentNumber();

  /// Devuelve la fecha de nacimiento guardada (para pre-llenar el form de login).
  Future<String?> getSavedBirthDate() =>
      ref.read(authRepositoryProvider).getSavedBirthDate();
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
