/// Base class for all exceptions in the data layer
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Server exception (HTTP errors, API failures)
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

/// Network exception (no connectivity, timeout)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
}

/// Firestore exception
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.details});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Storage exception (file upload/download errors)
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code, super.details});
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}

/// AI service exception (Gemini API errors)
class AIException extends AppException {
  const AIException(super.message, {super.code, super.details});
}

/// Location service exception
class LocationException extends AppException {
  const LocationException(super.message, {super.code, super.details});
}
