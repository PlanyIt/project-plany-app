import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/location_service.dart';
import 'package:front/ui/core/ui/bottom_bar/bottom_bar.dart';
import 'package:front/ui/core/ui/list/horizontal_plan_list.dart';
import 'package:front/ui/core/ui/placeholder/empty_state_widget.dart';
import 'package:front/ui/core/ui/search_bar/search_bar.dart';
import 'package:front/ui/dashboard/dashboard_screen.dart';
import 'package:front/ui/dashboard/view_models/dashboard_viewmodel.dart';
import 'package:front/ui/dashboard/widgets/category_cards.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:provider/provider.dart';

import '../../../testing/fakes/app.dart';
import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_category_repository.dart';
import '../../../testing/fakes/repositories/fake_plan_repository.dart';
import '../../../testing/fakes/services/fake_location_service.dart';

void main() {
  group('DashboardScreen tests', () {
    late DashboardViewModel viewModel;
    late FakeAuthRepository fakeAuthRepository;
    late FakePlanRepository fakePlanRepository;
    late FakeCategoryRepository fakeCategoryRepository;
    late FakeLocationService fakeLocationService;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      fakePlanRepository = FakePlanRepository();
      fakeCategoryRepository = FakeCategoryRepository();
      fakeLocationService = FakeLocationService();

      viewModel = DashboardViewModel(
        authRepository: fakeAuthRepository,
        categoryRepository: fakeCategoryRepository,
        planRepository: fakePlanRepository,
        locationService: fakeLocationService,
      );
    });

    Future<void> loadScreen(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => DashboardScreen(viewModel: viewModel),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const Scaffold(
              body: Text('Search Screen'),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(
              body: Text('Profile Screen'),
            ),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const Scaffold(
              body: Text('Create Plan Screen'),
            ),
          ),
          GoRoute(
            path: '/plan',
            builder: (context, state) => const Scaffold(
              body: Text('Plan Details Screen'),
            ),
          ),
        ],
      );

      await testApp(
        tester,
        ChangeNotifierProvider<LocationService>.value(
          value: fakeLocationService,
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                routerDelegate: router.routerDelegate,
                routeInformationParser: router.routeInformationParser,
                routeInformationProvider: router.routeInformationProvider,
                localizationsDelegates: const [
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('fr')],
                theme: ThemeData.light(),
              );
            },
          ),
        ),
      );
    }

    testWidgets('should load screen', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(DashboardScreen), findsOneWidget);
        expect(find.byType(BottomBar), findsOneWidget);
      });
    });

    testWidgets('should navigate to search when tapping search bar',
        (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await loadScreen(tester);

        await tester.tap(
          find.ancestor(
            of: find.byType(DashboardSearchBar),
            matching: find.byType(InkWell),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Search Screen'), findsOneWidget);
      });
    });

    testWidgets('shows loading shimmer for categories and plans',
        (WidgetTester tester) async {
      viewModel.load.execute();

      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.byType(CategoryCards), findsOneWidget);
        expect(find.byType(HorizontalPlanList), findsWidgets);
        expect(find.byType(EmptyStateWidget), findsNothing);
      });
    });

    testWidgets('shows location loading, error, and success states',
        (WidgetTester tester) async {
      // Loading
      fakeLocationService.fakeLoading = true;
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.textContaining('Localisation en cours'), findsOneWidget);
      });

      // Error
      fakeLocationService.fakeLoading = false;
      fakeLocationService.fakeErrorMessage = 'Erreur de localisation';
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.textContaining('Erreur de localisation'), findsOneWidget);
      });

      // Success
      fakeLocationService.fakeErrorMessage = null;
      fakeLocationService.fakePosition = Position(
        latitude: 48.0,
        longitude: 2.0,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        altitudeAccuracy: 1,
        headingAccuracy: 1,
      );
      await mockNetworkImages(() async {
        await loadScreen(tester);
        expect(find.textContaining('Position actualisée'), findsOneWidget);
      });
    });
  });
}
