import 'package:fpdart/fpdart.dart';
import 'package:darna/core/error/failures.dart';

/// Type alias for Either with Failure as the left value
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Type alias for synchronous Either
typedef SyncEither<T> = Either<Failure, T>;

/// Extension methods for working with Either<Failure, T>
extension EitherExtension<T> on Either<Failure, T> {
  /// Returns the value if Right, otherwise returns the default value
  T getOrElse(T Function() defaultValue) {
    return fold(
      (failure) => defaultValue(),
      (value) => value,
    );
  }

  /// Returns the value if Right, otherwise returns null
  T? getOrNull() {
    return fold(
      (failure) => null,
      (value) => value,
    );
  }

  /// Maps over the Right value
  Either<Failure, R> mapRight<R>(R Function(T value) mapper) {
    return map(mapper);
  }

  /// Maps over the Left value (Failure)
  Either<Failure, T> mapLeft(Failure Function(Failure failure) mapper) {
    return fold(
      (failure) => Left(mapper(failure)),
      (value) => Right(value),
    );
  }

  /// Executes different functions based on Left or Right
  R when<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) {
    return fold(onFailure, onSuccess);
  }

  // Note: isRight() and isLeft() methods are already available from Either
  // No need for additional getters that would cause recursion
}

/// Extension for Future<Either<Failure, T>>
extension FutureEitherExtension<T> on Future<Either<Failure, T>> {
  /// Maps over the Right value asynchronously
  Future<Either<Failure, R>> mapRight<R>(R Function(T value) mapper) async {
    final result = await this;
    return result.map(mapper);
  }

  /// Chains another async operation if Right
  Future<Either<Failure, R>> flatMapRight<R>(
    Future<Either<Failure, R>> Function(T value) mapper,
  ) async {
    final result = await this;
    return result.fold(
      (failure) => left(failure),
      (value) async => await mapper(value),
    );
  }

  /// Executes a callback when the result is Right
  Future<Either<Failure, T>> onSuccess(void Function(T value) callback) async {
    final result = await this;
    result.fold(
      (failure) {},
      (value) => callback(value),
    );
    return result;
  }

  /// Executes a callback when the result is Left (Failure)
  Future<Either<Failure, T>> onFailure(void Function(Failure failure) callback) async {
    final result = await this;
    result.fold(
      (failure) => callback(failure),
      (value) {},
    );
    return result;
  }

  /// Returns the value or throws an exception if Left
  Future<T> getOrThrow() async {
    final result = await this;
    return result.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
    );
  }
}
