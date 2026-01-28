import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and navigates to profile', (tester) async {
    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Verify we are on the Dashboard (assuming it starts there or login is bypassed/mocked)
    // Note: In real E2E, we might need to login first or use a testing flag to bypass login.
    // For this template, we'll verify the app starts.

    // Example: Find the "Profile" tab in BottomNavigationBar
    final profileTabFinder =
        find.byIcon(Icons.person); // Adjust icon if different

    // Since actual implementation details vary (Login flow etc),
    // we'll do a basic check that the app builds.
    expect(find.byType(MaterialApp), findsOneWidget);

    // TODO: Add specific navigation steps once Login is automated or mocked in E2E.
    // await tester.tap(profileTabFinder);
    // await tester.pumpAndSettle();
    // expect(find.text('My Profile'), findsOneWidget);
  });
}
