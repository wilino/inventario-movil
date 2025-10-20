import '../errors/failures.dart';

/// Tipo Result para manejar éxitos y fallos sin dependencias externas
sealed class Result<T> {
  const Result();
}

/// Resultado exitoso
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Resultado fallido
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extensiones para trabajar con Result más fácilmente
extension ResultExtensions<T> on Result<T> {
  /// Verifica si es un éxito
  bool get isSuccess => this is Success<T>;

  /// Verifica si es un error
  bool get isError => this is Error<T>;

  /// Obtiene el valor si es Success, null si es Error
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Error() => null,
  };

  /// Obtiene el error si es Error, null si es Success
  Failure? get errorOrNull => switch (this) {
    Success() => null,
    Error(:final failure) => failure,
  };

  /// Obtiene el valor o lanza una excepción
  T getOrThrow() => switch (this) {
    Success(:final value) => value,
    Error(:final failure) => throw Exception(failure.message),
  };

  /// Ejecuta una función según el resultado
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T value) onSuccess,
  ) => switch (this) {
    Success(:final value) => onSuccess(value),
    Error(:final failure) => onError(failure),
  };

  /// Transforma el valor si es Success
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Error(:final failure) => Error(failure),
  };

  /// Encadena operaciones que retornan Result
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Success(:final value) => transform(value),
    Error(:final failure) => Error(failure),
  };
}
