import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:front/ui/core/base/base_viewmodel.dart';

/// Generic provider wrapper for ViewModels
class ViewModelProvider<T extends BaseViewModel> extends StatelessWidget {
  final T Function() create;
  final Widget Function(BuildContext context, T viewModel) builder;
  final bool lazy;
  final void Function(T viewModel)? onInit;

  const ViewModelProvider({
    super.key,
    required this.create,
    required this.builder,
    this.lazy = true,
    this.onInit,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) {
        final viewModel = create();
        onInit?.call(viewModel);
        return viewModel;
      },
      lazy: lazy,
      child: Consumer<T>(
        builder: (context, viewModel, child) => builder(context, viewModel),
      ),
    );
  }
}

/// Multi-provider wrapper for multiple ViewModels
class MultiViewModelProvider extends StatelessWidget {
  final List<SingleChildWidget> providers;
  final Widget child;

  const MultiViewModelProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}

/// Utility extension to easily access ViewModels from context
extension ViewModelExtensions on BuildContext {
  /// Read a ViewModel without listening to changes
  T readViewModel<T extends BaseViewModel>() => read<T>();

  /// Watch a ViewModel and listen to changes
  T watchViewModel<T extends BaseViewModel>() => watch<T>();

  /// Select specific properties from a ViewModel
  R selectViewModel<T extends BaseViewModel, R>(R Function(T) selector) =>
      select<T, R>(selector);
}

/// Mixin for StatefulWidgets that need to interact with ViewModels
mixin ViewModelMixin<T extends StatefulWidget, VM extends BaseViewModel>
    on State<T> {
  VM get viewModel => context.readViewModel<VM>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onViewModelReady(viewModel);
    });
  }

  /// Called when the ViewModel is ready
  void onViewModelReady(VM viewModel) {}

  /// Listen to specific ViewModel changes
  void listenToViewModel<R>(
    R Function(VM) selector,
    void Function(R value) listener,
  ) {
    // This should be called in initState
    context.selectViewModel<VM, R>(selector);
  }
}
