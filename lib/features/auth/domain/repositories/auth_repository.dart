import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  });

  Future<User?> getSavedUser();
  Future<String?> getSavedDocumentNumber();
  Future<bool> getSavedRememberMe();
  Future<void> logout();
}
