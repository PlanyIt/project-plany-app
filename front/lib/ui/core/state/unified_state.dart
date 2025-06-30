import 'package:flutter/foundation.dart';
import 'package:front/core/utils/result.dart';

/// Unified state management for UI data loading
class UnifiedState<T> {
  final bool isLoading;
  final bool isInitial;
  final T? data;
  final String? error;

  const UnifiedState._({
    required this.isLoading,
    required this.isInitial,
    this.data,
    this.error,
  });

  /// Initial state before any loading
  const UnifiedState.initial()
      : isLoading = false,
        isInitial = true,
        data = null,
        error = null;

  /// Loading state
  const UnifiedState.loading()
      : isLoading = true,
        isInitial = false,
        data = null,
        error = null;

  /// Success state with data
  const UnifiedState.success(T data)
      : isLoading = false,
        isInitial = false,
        data = data,
        error = null;

  /// Error state
  const UnifiedState.error(String error)
      : isLoading = false,
        isInitial = false,
        data = null,
        error = error;

  /// Check if state has data
  bool get hasData => data != null;

  /// Check if state has error
  bool get hasError => error != null;

  /// Check if state is success
  bool get isSuccess => hasData && !hasError && !isLoading;

  /// Copy state with new values
  UnifiedState<T> copyWith({
    bool? isLoading,
    bool? isInitial,
    T? data,
    String? error,
  }) {
    return UnifiedState._(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedState<T> &&
        other.isLoading == isLoading &&
        other.isInitial == isInitial &&
        other.data == data &&
        other.error == error;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        isInitial.hashCode ^
        data.hashCode ^
        error.hashCode;
  }

  @override
  String toString() {
    return 'UnifiedState{isLoading: $isLoading, isInitial: $isInitial, data: $data, error: $error}';
  }
}

/// Base class for unified state management
abstract class UnifiedViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  /// Check if the ViewModel has been disposed
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Handle result and convert to UnifiedState
  UnifiedState<T> handleResult<T>(Result<T> result) {
    switch (result) {
      case Ok<T>():
        return UnifiedState.success(result.value);
      case Error<T>():
        return UnifiedState.error(result.error.toString());
    }
  }

  /// Execute an async operation and return UnifiedState
  Future<UnifiedState<T>> executeWithState<T>(
    Future<Result<T>> Function() operation,
  ) async {
    try {
      final result = await operation();
      return handleResult(result);
    } catch (e) {
      return UnifiedState.error(e.toString());
    }
  }
}
