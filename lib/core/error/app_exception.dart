sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Error de conexión con el servidor']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Credenciales no válidas']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Error del servidor']);
}
