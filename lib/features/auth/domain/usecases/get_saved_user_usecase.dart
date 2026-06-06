import 'package:mr_app/features/auth/domain/entities/user.dart';
import 'package:mr_app/features/auth/domain/repositories/auth_repository.dart';

class GetSavedUserUseCase {
  const GetSavedUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getSavedUser();
}
