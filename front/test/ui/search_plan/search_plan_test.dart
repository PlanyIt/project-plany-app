import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/repositories/category/category_repository.dart';
import 'package:front/data/repositories/plan/plan_repository.dart';
import 'package:front/ui/search_plan/search_screen.dart';
import 'package:front/ui/search_plan/view_models/search_view_model.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';

import '../../../testing/fakes/app.dart';
import '../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../testing/fakes/repositories/fake_plan_repository.dart';

void main() {
  group('SearchScreen tests', () {
    late SearchViewModel searchViewModel;
    late FakePlanRepository fakePlanRepository;
    late FakeCategoryRepository fakeCategoryRepository;

    setUp(() {
      fakePlanRepository = FakePlanRepository();
      fakeCategoryRepository = FakeCategoryRepository();

      searchViewModel = SearchViewModel(
        planRepository: fakePlanRepository,
        categoryRepository: fakeCategoryRepository,
      );
    });

    Future<void> loadScreen(WidgetTester tester) async {
      await testApp(
        tester,
        MultiProvider(
          providers: [
            Provider<PlanRepository>.value(value: fakePlanRepository),
            Provider<CategoryRepository>.value(value: fakeCategoryRepository),
          ],
          child: SearchScreen(viewModel: searchViewModel),
        ),
      );
    }

    testWidgets('should load screen with search bar',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        // Vérifie que la SearchBar est présente
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    testWidgets('should show CircularProgressIndicator when searching location',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        await tester.tap(find.byIcon(Icons.my_location));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });
  });
}
