import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/domain/models/category/category.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/dashboard/widgets/category_cards.dart';
import 'package:front/utils/command.dart';
import 'package:front/utils/result.dart';

import '../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../../testing/fakes/services/fake_location_service.dart';

class FakeDashboardViewModel extends DashboardViewModel {
  FakeDashboardViewModel({
    List<Category>? categories,
    bool isLoading = false,
  })  : _categories = categories ?? [],
        _isLoading = isLoading,
        super(
          categoryRepository: FakeCategoryRepository(),
          authRepository: FakeAuthRepository(),
          planRepository: FakePlanRepository(),
          locationService: FakeLocationService(),
        );

  final List<Category> _categories;
  final bool _isLoading;

  @override
  List<Category> get categories => _categories;

  @override
  bool get hasLoadedData => _categories.isNotEmpty;

  @override
  Command0 get load => _FakeLoadCommand(_isLoading);
}

class _FakeLoadCommand extends Command0<void> {
  @override
  final bool running;
  _FakeLoadCommand(this.running)
      : super(() {
          return Future.value(Result<void>.ok(null));
        });

  @override
  Future<Result<void>> execute() async {
    return Result.ok(null);
  }
}

void main() {
  testWidgets('Affiche le shimmer quand loading', (tester) async {
    final viewModel = FakeDashboardViewModel(isLoading: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryCards(viewModel: viewModel),
        ),
      ),
    );

    expect(find.byType(Container), findsWidgets); // shimmer container
  });

  testWidgets('Affiche les catégories', (tester) async {
    final categories = [
      Category(id: '1', name: 'Sport', color: '#FF0000', icon: 'sports'),
      Category(id: '2', name: 'Musique', color: '#00FF00', icon: 'music_note'),
    ];
    final viewModel = FakeDashboardViewModel(categories: categories);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryCards(viewModel: viewModel),
        ),
      ),
    );

    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Musique'), findsOneWidget);
  });

  testWidgets('Affiche le message aucune catégorie', (tester) async {
    final viewModel = FakeDashboardViewModel(categories: []);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryCards(viewModel: viewModel),
        ),
      ),
    );

    expect(find.text('Aucune catégorie disponible'), findsOneWidget);
  });

  testWidgets('Callback onPressed fonctionne', (tester) async {
    final categories = [
      Category(id: '1', name: 'Sport', color: '#FF0000', icon: 'sports'),
    ];
    final viewModel = FakeDashboardViewModel(categories: categories);

    Category? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryCards(
            viewModel: viewModel,
            onPressed: (cat) => tapped = cat,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sport'));
    expect(tapped, isNotNull);
    expect(tapped!.name, 'Sport');
  });
}
