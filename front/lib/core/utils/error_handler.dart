import 'dart:io';
import 'package:front/core/utils/exceptions.dart';
import 'package:logging/logging.dart';

/// Helper class to handle HTTP errors and convert them to appropriate exceptions
class ErrorHandler {
  static final _log = Logger('ErrorHandler');

  /// Convert HTTP status codes and response to appropriate exceptions
  static AppException handleHttpError(int statusCode, String message,
      [dynamic responseBody]) {
    String errorMessage = message;
    dynamic details;

    // Try to extract more detailed error information from response body
    if (responseBody != null && responseBody is Map<String, dynamic>) {
      final error = responseBody['error'];
      if (error != null) {
        if (error is Map<String, dynamic>) {
          errorMessage = error['message'] ?? message;
          details = error['details'];
        } else if (error is String) {
          errorMessage = error;
        }
      }
    }

    return ApiException.fromStatusCode(statusCode, errorMessage, details);
  }

  /// Handle network errors (connection issues, timeouts, etc.)
  static AppException handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return const NetworkException(
        'Pas de connexion Internet. Vérifiez votre connexion et réessayez.',
      );
    }

    if (error is HttpException) {
      return NetworkException(
        'Erreur de réseau: ${error.message}',
        {'uri': error.uri?.toString()},
      );
    }

    return NetworkException(
      'Erreur de connexion. Vérifiez votre connexion Internet.',
      {'originalError': error.toString()},
    );
  }

  /// Handle unknown errors and provide fallback
  static AppException handleUnknownError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    return ServerException(
      'Une erreur inattendue s\'est produite.',
      {'originalError': error.toString()},
    );
  }

  /// Get user-friendly message for display
  static String getUserFriendlyMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'Problème de connexion. Vérifiez votre réseau.';
      case AuthenticationException:
        return 'Session expirée. Veuillez vous reconnecter.';
      case ValidationException:
        return exception.message;
      case NotFoundException:
        return 'Ressource non trouvée.';
      case RateLimitException:
        final retryAfter = (exception as RateLimitException).retryAfter;
        if (retryAfter != null) {
          return 'Trop de requêtes. Réessayez dans ${retryAfter}s.';
        }
        return 'Trop de requêtes. Veuillez patienter.';
      case ServerException:
        return 'Erreur serveur. Veuillez réessayer plus tard.';
      default:
        return exception.message;
    }
  }

  /// Handles and converts exceptions to user-friendly messages
  static String handleError(Object error) {
    _log.severe('Error occurred: $error');

    if (error is AppException) {
      return error.message;
    }

    // Handle common Flutter/Dart exceptions
    if (error is FormatException) {
      return 'Format de données invalide';
    }

    if (error is TypeError) {
      return 'Erreur de type de données';
    }

    if (error is StateError) {
      return 'Erreur d\'état de l\'application';
    }

    if (error is ArgumentError) {
      return 'Paramètres invalides';
    }

    // Default fallback
    return 'Une erreur inattendue s\'est produite';
  }

  /// Logs error with context
  static void logError(Object error, StackTrace? stackTrace,
      [String? context]) {
    final contextStr = context != null ? '[$context] ' : '';
    _log.severe('${contextStr}Error: $error', error, stackTrace);
  }

  /// Converts HTTP status codes to appropriate exceptions
  static AppException statusCodeToException(int statusCode, [String? message]) {
    final defaultMessage = message ?? 'Erreur HTTP $statusCode';

    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Requête invalide');
      case 401:
        return AuthenticationException(message ?? 'Authentification requise');
      case 403:
        return AuthorizationException(message ?? 'Accès refusé');
      case 404:
        return NotFoundException(message ?? 'Ressource non trouvée');
      case 408:
        return TimeoutException(message ?? 'Délai d\'attente dépassé');
      case 409:
        return ValidationException(message ?? 'Conflit de données');
      case 422:
        return ValidationException(message ?? 'Données non traitables');
      case 429:
        return RateLimitException(message ?? 'Trop de requêtes');
      case 500:
        return ServerException(message ?? 'Erreur serveur interne');
      case 502:
        return NetworkException(message ?? 'Passerelle incorrecte');
      case 503:
        return ServerException(message ?? 'Service indisponible');
      case 504:
        return TimeoutException(message ?? 'Délai de passerelle dépassé');
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ValidationException(defaultMessage);
        } else if (statusCode >= 500) {
          return ServerException(defaultMessage);
        }
        return UnknownException(defaultMessage);
    }
  }

  /// Checks if an error is recoverable
  static bool isRecoverableError(Object error) {
    if (error is NetworkException ||
        error is TimeoutException ||
        error is ServerException) {
      return true;
    }
    return false;
  }

  /// Gets a user-friendly retry message
  static String getRetryMessage(Object error) {
    if (error is NetworkException) {
      return 'Vérifiez votre connexion et réessayez';
    }
    if (error is TimeoutException) {
      return 'Délai d\'attente dépassé, réessayez';
    }
    if (error is ServerException) {
      return 'Problème serveur, réessayez plus tard';
    }
    if (error is RateLimitException) {
      return 'Trop de tentatives, attendez avant de réessayer';
    }
    return 'Réessayez plus tard';
  }
}
