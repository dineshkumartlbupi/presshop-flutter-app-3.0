import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MockDio extends Mock implements Dio {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late MockSharedPreferences mockPrefs;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() async {
    mockDio = MockDio();
    mockPrefs = MockSharedPreferences();
    mockSecureStorage = MockFlutterSecureStorage();
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    // Setup Dio options
    when(() => mockDio.options).thenReturn(BaseOptions());
    when(() => mockDio.interceptors).thenReturn(Interceptors());

    // Setup Firebase stubs
    when(() => mockCrashlytics.recordError(any(), any(),
        reason: any(named: 'reason'),
        information: any(named: 'information'),
        printDetails: any(named: 'printDetails'),
        fatal: any(named: 'fatal'))).thenAnswer((_) async {});
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});

    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    when(() => mockAnalytics.logScreenView(
          screenName: any(named: 'screenName'),
          screenClass: any(named: 'screenClass'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    await sl.reset();
    sl.registerLazySingleton<FirebaseAnalytics>(() => mockAnalytics);
    sl.registerLazySingleton<FirebaseCrashlytics>(() => mockCrashlytics);
  });

  group('ApiClient Interceptor Tests', () {
    test('should add Authorization header if token exists in SharedPreferences',
        () async {
      // arrange
      ApiClient(mockDio, mockPrefs, mockSecureStorage);
      const tToken = 'test_token';
      when(() => mockPrefs.getString(SharedPreferencesKeys.tokenKey))
          .thenReturn(tToken);
      when(() => mockPrefs.getString(SharedPreferencesKeys.deviceIdKey))
          .thenReturn('device123');

      final options = RequestOptions(path: '/test');
      final completer = Completer<void>();

      final interceptor = mockDio.interceptors
          .firstWhere((i) => i is InterceptorsWrapper) as InterceptorsWrapper;

      // act
      interceptor.onRequest(options, TestRequestInterceptorHandler(completer));
      await completer.future;

      // assert
      expect(
          options.headers[SharedPreferencesKeys.headerKey], 'Bearer $tToken');
      expect(options.headers[SharedPreferencesKeys.headerDeviceIdKey],
          'device123');
      expect(options.headers[SharedPreferencesKeys.headerDeviceTypeKey],
          contains('mobile-flutter-'));
    });

    test(
        'should sync token from SecureStorage to SharedPreferences if missing in Prefs',
        () async {
      // arrange
      ApiClient(mockDio, mockPrefs, mockSecureStorage);
      const tToken = 'secure_token';
      when(() => mockPrefs.getString(SharedPreferencesKeys.tokenKey))
          .thenReturn(null);
      when(() => mockSecureStorage.read(key: SharedPreferencesKeys.tokenKey))
          .thenAnswer((_) async => tToken);
      when(() => mockPrefs.setString(SharedPreferencesKeys.tokenKey, tToken))
          .thenAnswer((_) async => true);
      when(() => mockPrefs.getString(SharedPreferencesKeys.deviceIdKey))
          .thenReturn('device123');

      final options = RequestOptions(path: '/test');
      final completer = Completer<void>();
      final interceptor = mockDio.interceptors
          .firstWhere((i) => i is InterceptorsWrapper) as InterceptorsWrapper;

      // act
      interceptor.onRequest(options, TestRequestInterceptorHandler(completer));
      await completer.future;

      // assert
      verify(() => mockPrefs.setString(SharedPreferencesKeys.tokenKey, tToken))
          .called(1);
      expect(
          options.headers[SharedPreferencesKeys.headerKey], 'Bearer $tToken');
    });

    test('should log error to AppLogger and track analytics on error',
        () async {
      // arrange
      ApiClient(mockDio, mockPrefs, mockSecureStorage);
      final err = DioException(
        requestOptions: RequestOptions(path: '/test', method: 'GET'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
      );
      final completer = Completer<void>();
      final interceptor = mockDio.interceptors
          .firstWhere((i) => i is InterceptorsWrapper) as InterceptorsWrapper;

      // act
      interceptor.onError(err, TestErrorInterceptorHandler(completer));
      await completer.future;

      // assert
      // Verification of AppLogger happens via the side effects (Crashlytics/Analytics)
      verify(() => mockCrashlytics.recordError(any(), any(),
          reason: any(named: 'reason'))).called(1);
    });
  });
}

class TestRequestInterceptorHandler extends RequestInterceptorHandler {
  TestRequestInterceptorHandler(this.completer);
  final Completer<void> completer;

  @override
  void next(RequestOptions requestOptions) {
    completer.complete();
  }
}

class TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  TestErrorInterceptorHandler(this.completer);
  final Completer<void> completer;

  @override
  void next(DioException err) {
    completer.complete();
  }
}
