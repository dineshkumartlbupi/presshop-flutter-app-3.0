import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/referral/presentation/pages/refer_screen.dart';
import 'package:presshop/main.dart' as app_main;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Ensure GetIt is clean
    GetIt.instance.reset();
  });

  testWidgets('ReferScreen displays referral code', (tester) async {
    // 1. Mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      SharedPreferencesKeys.referralCode: 'TEST_CODE_123',
      SharedPreferencesKeys.firstNameKey: 'John',
      SharedPreferencesKeys.totalHopperArmy: '5'
    });

    // 2. Initialize global variable
    app_main.sharedPreferences = await SharedPreferences.getInstance();

    // 3. Pump widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ReferScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 4. Verify code is displayed
    expect(find.text('TEST_CODE_123'), findsOneWidget);
    expect(find.text('Hoppers unite — let’s grow the army'), findsOneWidget);
  });
}
