import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Profile Flow: Login -> Menu -> Edit Profile -> Update',
      (tester) async {
    // 1. Launch App
    app.main();
    await tester.pumpAndSettle();

    // 2. Login
    final emailField = find.widgetWithText(
        TextFormField, "Enter user name / phone number / email Id");
    if (emailField.evaluate().isNotEmpty) {
      final passwordField =
          find.widgetWithText(TextFormField, "Enter password *");
      final loginButton = find.widgetWithText(ElevatedButton, "Sign In");

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
    }

    // 3. Open Menu
    // The menu icon is in the app bar. It's an Image asset "assets/icons/menu3.png".
    // We can find it by type Image and check logic, or find the wrapping InkWell.
    // Or simpler: find by widget that contains the menu icon image.
    final menuIconFinder = find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        final assetImage = widget.image as AssetImage;
        return assetImage.assetName.contains('menu3.png');
      }
      return false;
    });

    expect(menuIconFinder, findsOneWidget);
    await tester.tap(menuIconFinder);
    await tester.pumpAndSettle();

    // 4. Tap "Edit profile"
    final editProfileItem = find.text("Edit profile");
    expect(editProfileItem, findsOneWidget);
    await tester.tap(editProfileItem);
    await tester.pumpAndSettle();

    // 5. Verify Edit Profile Screen
    // Look for "Edit profile" title or fields.
    expect(find.text("Edit profile"), findsAtLeastNWidgets(1));

    // 6. Modify a field (e.g., First Name)
    final firstNameField =
        find.widgetWithText(TextFormField, "Enter first name *");
    // If not found by text, try finding by basic TextFormField
    if (firstNameField.evaluate().isNotEmpty) {
      await tester.enterText(firstNameField, "UpdatedName");
      await tester.pumpAndSettle();
    }

    // 7. Save
    final updateButton = find.widgetWithText(ElevatedButton, "Update");
    if (updateButton.evaluate().isNotEmpty) {
      await tester.tap(updateButton);
      await tester.pumpAndSettle();
      // Verify success or navigation
    }
  });
}
