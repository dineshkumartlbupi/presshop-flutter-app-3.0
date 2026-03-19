import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/domain/entities/user.dart';
import 'package:presshop/features/authentication/domain/usecases/forgot_password.dart';
import 'package:presshop/features/authentication/domain/usecases/login_user.dart';
import 'package:presshop/features/authentication/domain/usecases/reset_password.dart';
import 'package:presshop/features/authentication/domain/usecases/social_login_user.dart';
import 'package:presshop/features/authentication/domain/usecases/verify_forgot_password_otp.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_state.dart';

class MockLoginUser extends Mock implements LoginUser {}

class MockSocialLoginUser extends Mock implements SocialLoginUser {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockVerifyForgotPasswordOtp extends Mock
    implements VerifyForgotPasswordOtp {}

class MockResetPassword extends Mock implements ResetPassword {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late AuthBloc bloc;
  late MockLoginUser mockLoginUser;
  late MockSocialLoginUser mockSocialLoginUser;
  late MockForgotPassword mockForgotPassword;
  late MockVerifyForgotPasswordOtp mockVerifyForgotPasswordOtp;
  late MockResetPassword mockResetPassword;
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUpAll(() {
    registerFallbackValue(LoginParams(username: '', password: ''));
    registerFallbackValue(SocialLoginParams(
        socialType: '', socialId: '', email: '', name: '', photoUrl: ''));
  });

  setUp(() async {
    mockLoginUser = MockLoginUser();
    mockSocialLoginUser = MockSocialLoginUser();
    mockForgotPassword = MockForgotPassword();
    mockVerifyForgotPasswordOtp = MockVerifyForgotPasswordOtp();
    mockResetPassword = MockResetPassword();
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    // Reset sl and register mocks for AppLogger
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

    bloc = AuthBloc(
      loginUser: mockLoginUser,
      socialLoginUser: mockSocialLoginUser,
      forgotPassword: mockForgotPassword,
      verifyForgotPasswordOtp: mockVerifyForgotPasswordOtp,
      resetPassword: mockResetPassword,
    );
  });

  final tUser = User(
    id: '1',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
    userName: 'testuser',
    phone: '1234567890',
  );

  group('AuthBloc Tracking Tests', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] and tracks successful login',
      build: () {
        when(() => mockLoginUser(any())).thenAnswer((_) async => Right(tUser));
        when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'))).thenAnswer((_) async => {});
        when(() => mockAnalytics.setUserId(id: any(named: 'id')))
            .thenAnswer((_) async => {});
        when(() => mockCrashlytics.setUserIdentifier(any()))
            .thenAnswer((_) async => {});
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
          username: 'test@example.com', password: 'password')),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
      verify: (_) {
        verify(() => mockAnalytics.logEvent(
              name: EventNames.userLogin,
              parameters: any(named: 'parameters'),
            )).called(1);
        verify(() => mockAnalytics.setUserId(id: tUser.id)).called(1);
        verify(() => mockCrashlytics.setUserIdentifier(tUser.id)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSocialSignUpRequired] when social user is not registered',
      build: () {
        when(() => mockSocialLoginUser(any())).thenAnswer((_) async =>
            const Left(
                UserNotRegisteredFailure(message: 'User not registered')));
        return bloc;
      },
      act: (bloc) => bloc.add(const SocialLoginRequested(
        socialType: 'google',
        socialId: '123',
        email: 'test@example.com',
        name: 'Test',
        photoUrl: '',
      )),
      expect: () => [
        AuthLoading(),
        const AuthSocialSignUpRequired(
          socialType: 'google',
          socialId: '123',
          email: 'test@example.com',
          name: 'Test',
          photoUrl: '',
        ),
      ],
    );

    group('Forgot & Reset Password', () {
      test('register forgot password params fallback', () {
        registerFallbackValue(
            const VerifyForgotPasswordOtpParams(email: '', otp: ''));
        registerFallbackValue(
            const ResetPasswordParams(email: '', password: ''));
      });

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, ForgotPasswordSent] when forgotPassword succeeds',
        build: () {
          when(() => mockForgotPassword(any()))
              .thenAnswer((_) async => const Right('123456'));
          return bloc;
        },
        act: (bloc) =>
            bloc.add(const ForgotPasswordRequested('test@example.com')),
        expect: () => [
          AuthLoading(),
          const ForgotPasswordSent(otp: '123456'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, ForgotPasswordOtpVerified] when OTP verification succeeds',
        build: () {
          when(() => mockVerifyForgotPasswordOtp(any()))
              .thenAnswer((_) async => const Right(true));
          return bloc;
        },
        act: (bloc) => bloc.add(const VerifyForgotPasswordOtpRequested(
            email: 'test@example.com', otp: '123456')),
        expect: () => [
          AuthLoading(),
          ForgotPasswordOtpVerified(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, ResetPasswordSuccess] when resetPassword succeeds',
        build: () {
          when(() => mockResetPassword(any()))
              .thenAnswer((_) async => const Right(true));
          return bloc;
        },
        act: (bloc) => bloc.add(const ResetPasswordSubmitted(
            email: 'test@example.com', password: 'newpassword')),
        expect: () => [
          AuthLoading(),
          ResetPasswordSuccess(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when resetPassword fails',
        build: () {
          when(() => mockResetPassword(any()))
              .thenAnswer((_) async => const Right(false));
          return bloc;
        },
        act: (bloc) => bloc.add(const ResetPasswordSubmitted(
            email: 'test@example.com', password: 'newpassword')),
        expect: () => [
          AuthLoading(),
          const AuthError(message: "Failed to reset password"),
        ],
      );
    });
  });
}
