import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/di/injection_container.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() async {
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    // Reset sl and register mocks
    await sl.reset();
    sl.registerLazySingleton<FirebaseAnalytics>(() => mockAnalytics);
    sl.registerLazySingleton<FirebaseCrashlytics>(() => mockCrashlytics);

    // Default mocks for Firebase
    when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'))).thenAnswer((_) async => {});
    when(() => mockAnalytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async => {});
    when(() => mockAnalytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'))).thenAnswer((_) async => {});
    when(() => mockCrashlytics.recordError(any(), any(),
        reason: any(named: 'reason'),
        information: any(named: 'information'),
        printDetails: any(named: 'printDetails'),
        fatal: any(named: 'fatal'))).thenAnswer((_) async => {});
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async => {});
    when(() => mockCrashlytics.setUserIdentifier(any()))
        .thenAnswer((_) async => {});
    when(() => mockCrashlytics.setCustomKey(any(), any()))
        .thenAnswer((_) async => {});
  });

  tearDown(() async {
    await sl.reset();
  });

  group('AppLogger Tests', () {
    test('trackEvent calls analytics.logEvent', () async {
      const eventName = 'test_event';
      const parameters = {'key': 'value'};

      when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          )).thenAnswer((_) async => {});

      AppLogger.trackEvent(eventName, parameters: parameters);

      verify(() => mockAnalytics.logEvent(
            name: eventName,
            parameters: any(named: 'parameters'),
          )).called(1);
    });

    test('error logs to crashlytics', () async {
      const errorMsg = 'test error';
      final exception = Exception(errorMsg);
      final stackTrace = StackTrace.current;

      when(() => mockCrashlytics.recordError(
            any(),
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => {});

      AppLogger.error(errorMsg,
          error: exception, stackTrace: stackTrace, trackAnalytics: true);

      verify(() => mockCrashlytics.recordError(
            exception,
            stackTrace,
            reason: errorMsg,
          )).called(1);
    });

    test('setUserIdentity sets user id', () async {
      const userId = 'user_123';

      when(() => mockAnalytics.setUserId(id: any(named: 'id')))
          .thenAnswer((_) async => {});
      when(() => mockCrashlytics.setUserIdentifier(any()))
          .thenAnswer((_) async => {});

      AppLogger.setUserIdentity(userId: userId);

      verify(() => mockAnalytics.setUserId(id: userId)).called(1);
      verify(() => mockCrashlytics.setUserIdentifier(userId)).called(1);
    });
  });
}
