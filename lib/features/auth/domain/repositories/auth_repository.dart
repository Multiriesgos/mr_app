import 'package:mr_app/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<User> login({
    required String documentNumber,
    required String birthDate,
    required bool rememberMe,
  });

  Future<User?> getSavedUser();
  Future<String?> getSavedDocumentNumber();
  Future<String?> getSavedBirthDate();
  Future<bool> getSavedRememberMe();
  Future<void> logout();
}
