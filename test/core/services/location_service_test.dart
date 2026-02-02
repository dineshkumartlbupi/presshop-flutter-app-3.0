import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() async {
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    await sl.reset();
    sl.registerLazySingleton<FirebaseAnalytics>(() => mockAnalytics);
    sl.registerLazySingleton<FirebaseCrashlytics>(() => mockCrashlytics);
  });

  group('LocationService Tracking Tests', () {
    test('skeleton test', () {});
  });
}
