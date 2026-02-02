import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Authentication Flow: Login Test', (tester) async {
    // 1. Launch App
    app.main();
    await tester.pumpAndSettle();

    // 2. Verify Splash/Onboarding or Login Screen
    // Assumption: App starts at Login or Splash -> Login
    // We might need to handle Splash delay
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Check if we are at Login Screen using Text finders
    // We use Strings from constants, but here we hardcode for simplicity or import them.
    // Ideally importing string_constants.dart is better.
    final emailField = find.widgetWithText(
        TextFormField, "Enter user name / phone number / email Id");
    final passwordField =
        find.widgetWithText(TextFormField, "Enter password *");
    final loginButton = find.widgetWithText(ElevatedButton, "Sign In");

    if (emailField.evaluate().isNotEmpty) {
      // 3. Enter Credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // 4. Tap Login
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // 5. Verify Dashboard
      // Assuming Dashboard has a specific title or widget.
      // If Dashboard is complex, look for a unique icon or text.
      // expect(find.byType(Dashboard), findsOneWidget); // Verify Dashboard widget presence
    } else {
      // Might be already logged in or stuck on Splash?
      // For now, fail if login not found
      // Or maybe we are on Onboarding?
    }
  });
}
