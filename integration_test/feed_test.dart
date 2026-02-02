import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Feed Flow: Load and Scroll', (tester) async {
    // 1. Launch App
    app.main();
    await tester.pumpAndSettle();

    // 2. Login (This is repetitive, ideally abstract this)
    // For now, assume simple login flow or already logged in

    // Check if at login
    final emailField = find.widgetWithText(
        TextFormField, "Enter user name / phone number / email Id");
    if (emailField.evaluate().isNotEmpty) {
      final passwordField =
          find.widgetWithText(TextFormField, "Enter password *");
      final loginButton = find.widgetWithText(ElevatedButton, "Sign In");

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);

      await tester.pumpAndSettle(); // Wait for navigation
    }

    // 3. Verify Dashboard / Feed
    // Assuming Dashboard opens at Feed tab (index 0)
    // Or tap Feed tab
    // final feedTab = find.byIcon(Icons.feed); // Replace with actual icon/text
    // await tester.tap(feedTab);
    // await tester.pumpAndSettle();

    // 4. Check for feed items
    // Assuming a ListView or similar.
    // Try to find any feed item.
    // We can use find.byType(NewsCard) or something similar if we know the widget class.
    // Or just check for scrollable.

    await tester.pumpAndSettle(const Duration(seconds: 2));

    final listFinder =
        find.byType(Scrollable).first; // Find the first scrollable
    expect(listFinder, findsOneWidget);

    // 5. Scroll down
    await tester.drag(listFinder, const Offset(0, -300));
    await tester.pumpAndSettle();

    // 6. Tap an item (if possible)
    // await tester.tap(find.byType(InkWell).first);
    // await tester.pumpAndSettle();
    // expect(find.text('Details'), findsOneWidget);
  });
}
