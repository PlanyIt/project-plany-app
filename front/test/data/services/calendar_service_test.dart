import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/data/services/calendar_service.dart';
import 'package:front/domain/models/plan/plan.dart';
import 'package:mocktail/mocktail.dart';

class FakeSnackBar extends Fake implements SnackBar {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FakeSnackBar';
  }
}

class FakeScaffoldFeatureController extends Fake
    implements ScaffoldFeatureController<SnackBar, SnackBarClosedReason> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSnackBar());
  });

  late Plan plan;

  setUp(() {
    plan = Plan(id: '1', title: 'Plan Test', description: 'Desc test');
  });

  testWidgets('should do nothing if plan is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await CalendarService.addPlanToCalendar(context, null);
                },
                child: const Text('Test'),
              );
            },
          ),
        ),
      ),
    );
    // Tap the button to trigger the function
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    // No snackbar should be shown
    expect(find.byType(SnackBar), findsNothing);
  });
}
