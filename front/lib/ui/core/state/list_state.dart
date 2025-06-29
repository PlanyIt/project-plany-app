/// Represents different states of a list view
enum ListViewState {
  initial,
  loading,
  loadingMore,
  success,
  empty,
  error,
  refreshing,
}

/// Generic class to manage list state consistently across the app
class ListState<T> {
  final ListViewState state;
  final List<T> items;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final int? totalCount;

  const ListState({
    required this.state,
    this.items = const [],
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.totalCount,
  });

  /// Create initial state
  factory ListState.initial() => const ListState(state: ListViewState.initial);

  /// Create loading state
  factory ListState.loading() => const ListState(state: ListViewState.loading);

  /// Create success state with items
  factory ListState.success({
    required List<T> items,
    bool hasMore = true,
    int currentPage = 1,
    int? totalCount,
  }) =>
      ListState(
        state: items.isEmpty ? ListViewState.empty : ListViewState.success,
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        totalCount: totalCount,
      );

  /// Create error state
  factory ListState.error(String error) => ListState(
        state: ListViewState.error,
        error: error,
      );

  /// Copy with new values
  ListState<T> copyWith({
    ListViewState? state,
    List<T>? items,
    String? error,
    bool? hasMore,
    int? currentPage,
    int? totalCount,
  }) {
    return ListState(
      state: state ?? this.state,
      items: items ?? this.items,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// Convert to loading more state
  ListState<T> toLoadingMore() => copyWith(state: ListViewState.loadingMore);

  /// Convert to refreshing state
  ListState<T> toRefreshing() => copyWith(state: ListViewState.refreshing);

  /// Add more items (for pagination)
  ListState<T> addItems(List<T> newItems, {bool? hasMore}) {
    final allItems = [...items, ...newItems];
    return copyWith(
      state: allItems.isEmpty ? ListViewState.empty : ListViewState.success,
      items: allItems,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage + 1,
    );
  }

  /// Replace all items (for refresh)
  ListState<T> replaceItems(List<T> newItems, {bool? hasMore}) {
    return copyWith(
      state: newItems.isEmpty ? ListViewState.empty : ListViewState.success,
      items: newItems,
      hasMore: hasMore ?? true,
      currentPage: 1,
    );
  }

  /// Update a specific item
  ListState<T> updateItem(T item, bool Function(T) predicate) {
    final updatedItems = items
        .map((existingItem) => predicate(existingItem) ? item : existingItem)
        .toList();

    return copyWith(items: updatedItems);
  }

  /// Remove an item
  ListState<T> removeItem(bool Function(T) predicate) {
    final filteredItems = items.where((item) => !predicate(item)).toList();
    return copyWith(
      items: filteredItems,
      state:
          filteredItems.isEmpty ? ListViewState.empty : ListViewState.success,
    );
  }

  /// Pattern matching method for UI
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(List<T> items) success,
    required R Function() empty,
    required R Function(String error) error,
  }) {
    if (isInitial) {
      return initial();
    } else if (isLoading) {
      return loading();
    } else if (isError) {
      return error(this.error!);
    } else if (hasData) {
      return success(items);
    } else {
      return empty();
    }
  }

  /// Simplified when method for common cases
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(List<T> items)? success,
    R Function()? empty,
    R Function(String error)? error,
    required R Function() orElse,
  }) {
    return when(
      initial: initial ?? orElse,
      loading: loading ?? orElse,
      success: success ?? (items) => orElse(),
      empty: empty ?? orElse,
      error: error ?? (err) => orElse(),
    );
  }

  /// Convenience getters
  bool get isLoading => state == ListViewState.loading;
  bool get isLoadingMore => state == ListViewState.loadingMore;
  bool get isRefreshing => state == ListViewState.refreshing;
  bool get isSuccess => state == ListViewState.success;
  bool get isEmpty => state == ListViewState.empty;
  bool get isError => state == ListViewState.error;
  bool get isInitial => state == ListViewState.initial;
  bool get hasData => items.isNotEmpty;
  bool get canLoadMore => hasMore && !isLoading && !isLoadingMore;
}
