/// Base class for all failures in the application
sealed class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Server-side failure (e.g., API errors, backend issues)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// Network connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

/// Authentication and authorization failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

/// Validation failures (e.g., form validation)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.details});
}

/// Permission failures (e.g., location, camera)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.details});
}

/// Unexpected or unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code, super.details});
}

/// Firestore-specific failures
class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message, {super.code, super.details});
}

/// Storage failures (e.g., Firebase Storage, file uploads)
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code, super.details});
}

/// AI/ML model failures (e.g., Gemini API errors)
class AIFailure extends Failure {
  const AIFailure(super.message, {super.code, super.details});
}

/// Maps and location service failures
class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code, super.details});
}
