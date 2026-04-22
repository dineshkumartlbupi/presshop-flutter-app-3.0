import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Test', () {
    testWidgets('Verify login flow with incorrect credentials shows error',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // --- NEW: Handle Walkthrough/Onboarding ---
      // We check if we are on the Walkthrough screen by looking for the "Skip" text
      final skipButton = find.text(AppStrings.skipText);
      if (skipButton.evaluate().isNotEmpty) {
        await tester.tap(skipButton);
        await tester.pumpAndSettle();
      }
      // ------------------------------------------

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

      // 3. Verify error dialog appears (AuthError state in Bloc leads to commonErrorDialogDialog)
      // Since it shows a dialog, we look for one of the texts in the dialog (e.g., "Error" or the expected message)
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
