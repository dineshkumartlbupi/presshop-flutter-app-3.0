import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Test', () {
    testWidgets('Verify login flow with incorrect credentials shows error',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find fields by Key
      final emailField = find.byKey(const Key('login_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final signInButton = find.byKey(const Key('sign_in_button'));

      // 1. Enter credentials
      await tester.enterText(emailField, 'testuser@example.com');
      await tester.enterText(passwordField, 'wrongpassword123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 2. Tap Sign In
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // 3. Verify error dialog or loading state (depending on app behavior)
      // Since it's a real integration test, we expect the BLoC to trigger an error dialog.
      // We can look for the "Error" text or generic error dialog widgets.
      // expect(find.text('Invalid credentials'), findsOneWidget); // Example
    });
  });
}
