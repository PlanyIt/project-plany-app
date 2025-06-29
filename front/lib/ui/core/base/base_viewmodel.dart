import 'package:flutter/foundation.dart';
import 'package:front/utils/result.dart';

/// Base class for all ViewModels to ensure consistent state management
abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  bool _isLoading = false;
  String? _error;

  /// Indicates if the ViewModel is currently loading
  bool get isLoading => _isLoading;

  /// Current error message, if any
  String? get error => _error;

  /// Check if the ViewModel has been disposed
  bool get isDisposed => _isDisposed;

  /// Set loading state and notify listeners
  void setLoading(bool loading) {
    if (_isDisposed) return;
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error state and notify listeners
  void setError(String? error) {
    if (_isDisposed) return;
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    setError(null);
  }

  /// Safe notify listeners that checks disposal state
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Handle result and update loading/error states accordingly
  void handleResult<T>(
    Result<T> result, {
    void Function(T value)? onSuccess,
    void Function(Exception error)? onError,
  }) {
    switch (result) {
      case Ok<T>():
        clearError();
        onSuccess?.call(result.value);
        break;
      case Error<T>():
        setError(result.error.toString());
        onError?.call(result.error);
        break;
    }
  }

  /// Execute an async operation with automatic loading state management
  Future<T?> executeWithLoading<T>(
    Future<Result<T>> Function() operation, {
    void Function(T value)? onSuccess,
    void Function(Exception error)? onError,
    bool clearErrorBeforeExecution = true,
  }) async {
    if (clearErrorBeforeExecution) clearError();
    setLoading(true);

    try {
      final result = await operation();
      handleResult(result, onSuccess: onSuccess, onError: onError);

      if (result is Ok<T>) {
        return result.value;
      }
      return null;
    } catch (e) {
      setError(e.toString());
      onError?.call(Exception(e.toString()));
      return null;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
