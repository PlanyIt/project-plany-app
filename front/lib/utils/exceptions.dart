/// Base exception class for application-specific errors
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message, [this.details]);

  final Map<String, dynamic>? details;
}

/// Exception thrown when API calls fail
class ApiException extends AppException {
  const ApiException(super.message, this.statusCode, [this.details]);

  final int statusCode;
  final Map<String, dynamic>? details;

  /// Factory constructor to create ApiException from status code
  factory ApiException.fromStatusCode(int statusCode, String message,
      [Map<String, dynamic>? details]) {
    return ApiException(message, statusCode, details);
  }
}

/// Exception thrown when storage operations fail
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Exception thrown when rate limit is exceeded
class RateLimitException extends AppException {
  const RateLimitException(super.message, [this.retryAfter]);

  final int? retryAfter;
}

/// Exception thrown for unknown errors
class UnknownException extends AppException {
  const UnknownException(super.message);
}

/// Exception thrown when user is not authorized
class AuthorizationException extends AppException {
  const AuthorizationException(super.message);
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Exception thrown when data parsing fails
class ParseException extends AppException {
  const ParseException(super.message);
}

/// Exception thrown when connection timeout occurs
class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

/// Exception thrown when server is unavailable
class ServerException extends AppException {
  const ServerException(super.message, [this.details]);

  final Map<String, dynamic>? details;
}
