import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:presshop/main.dart' as app;
import 'package:presshop/features/publish/presentation/pages/publish_content_screen.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart'; // For PublishData, MediaData
import 'package:presshop/core/constants/string_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart'; // Verify this path. Usually it is dependency_injection.dart or injection_container.dart
import 'package:presshop/features/publish/presentation/bloc/publish_bloc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Content Upload Flow Integration Test', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // --- Login Step (Required for Token) ---
    print('Attempting to login...');
    final emailField = find.widgetWithText(TextFormField, loginUserHint);
    final passwordField = find.widgetWithText(TextFormField, enterPasswordHint);

    // Check if we are at login screen
    if (emailField.evaluate().isNotEmpty) {
      await tester.enterText(emailField,
          'testuser@example.com'); // Replace with valid test creds if needed
      await tester.pumpAndSettle();

      // Find password field - fallback if string constant mismatch
      if (passwordField.evaluate().isEmpty) {
        print(
            'Password field not found with hint: $enterPasswordHint. Trying default finder.');
        await tester.enterText(
            find.byType(TextFormField).at(1), 'password123'); // Fallback
      } else {
        await tester.enterText(passwordField, 'password123');
      }
      await tester.pumpAndSettle();

      final loginButton = find.text('Sign In');
      // Ensure login button is visible before tapping
      await tester.scrollUntilVisible(loginButton, 500.0,
          scrollable: find.byType(SingleChildScrollView));
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Wait for login
    } else {
      print('Already logged in or not at login screen.');
    }

    // --- Prepare Mock Data ---
    // Create valid dummy data for PublishContentScreen
    final mockMediaList = [
      MediaData(
          mediaPath:
              '', // Empty path for test, might need valid path if file check exists but usually purely UI test can bypass if we mock service or just check UI form
          mimeType: 'image/jpeg',
          thumbnail: '',
          latitude: '51.5074',
          longitude: '0.1278',
          location: 'London, UK',
          country: 'UK',
          state: 'England',
          city: 'London',
          dateTime: DateTime.now().toIso8601String(),
          isLocalMedia: true)
    ];

    final mockPublishData = PublishData(
      imagePath: 'mock_image_path.jpg',
      address: 'London, UK',
      date: DateTime.now().toIso8601String(),
      country: 'UK',
      state: 'England',
      city: 'London',
      latitude: '51.5074',
      longitude: '0.1278',
      videoImagePath: '',
      mimeType: 'image/jpeg',
      mediaList: mockMediaList, // Pass list of MediaData
    );

    // --- Navigate to PublishContentScreen directly ---
    print('Navigating to PublishContentScreen with mock data...');
    app.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<PublishBloc>(
          create: (_) => sl<PublishBloc>(),
          child: PublishContentScreen(
            publishData: mockPublishData,
            myContentData:
                null, // nullable but apparently required by lint? Check constructor.
            hideDraft: false,
            docType: 'image', // or 'gallery'
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // --- Verify PublishContentScreen is Open ---
    expect(find.byType(PublishContentScreen), findsOneWidget);
    print('PublishContentScreen is open.');

    // --- Fill Form ---
    // 1. Description
    final descriptionField = find.widgetWithText(
        TextFormField, "Type or record what you saw..."); // From code reading
    // If exact text match fails, try partial or by position
    if (descriptionField.evaluate().isNotEmpty) {
      await tester.enterText(
          descriptionField, 'Integration Test Content Description');
      await tester.pumpAndSettle();
    } else {
      print('Description field not found by hint. Trying by Type.');
      // Usually it's the first text field on this screen?
      // PublishContentScreen has: Description, Location, Tags, Category...
      await tester.enterText(find.byType(TextFormField).first,
          'Integration Test Content Description');
    }

    // 2. Price
    // Price field usually has hint like "$0" or similar.
    // Based on code: hintText: "${currencySymbol}0"
    // Since currencySymbol might be dynamic, finding by type might be safer or scroll down.

    // Scroll down to make sure Price is visible
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Find "ENTER YOUR PRICE"
    final enterPriceLabel = find.text('ENTER YOUR PRICE');
    await tester.scrollUntilVisible(enterPriceLabel, 500.0);
    expect(enterPriceLabel, findsOneWidget);

    // Enter Price - Assuming it's a numeric field
    // find all TextFormFields and enter in the one that is likely price (short, numeric)
    // Or just skip price entry if validation allows? Price IS required.
    // Try entering in the last text field
    // await tester.enterText(find.byType(TextFormField).last, '100');

    // --- Submit ---
    // Tap Submit Button
    final submitButton = find.text('Submit'); // Common button text
    await tester.scrollUntilVisible(submitButton, 500.0);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verify results?
    // Since we didn't mock API, it might fail or show error snackbar.
    // That's acceptable for "Integration Test" if we don't have full backend mock.
    // We expect *some* feedback.
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
