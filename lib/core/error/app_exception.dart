sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}
