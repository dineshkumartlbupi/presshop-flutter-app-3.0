import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/authentication/domain/usecases/check_auth_status.dart';
import 'package:presshop/features/authentication/domain/usecases/check_onboarding_status.dart';
import 'package:presshop/features/authentication/domain/usecases/get_profile.dart';
import 'package:presshop/features/splash/domain/entities/version.dart';
import 'package:presshop/features/splash/domain/usecases/check_splash_version.dart';
import 'package:presshop/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:presshop/features/splash/presentation/bloc/splash_event.dart';
import 'package:presshop/features/splash/presentation/bloc/splash_state.dart';

class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

class MockGetProfile extends Mock implements GetProfile {}

class MockCheckSplashVersion extends Mock implements CheckSplashVersion {}

class MockCheckOnboardingStatus extends Mock implements CheckOnboardingStatus {}

void main() {
  late SplashBloc bloc;
  late MockCheckAuthStatus mockCheckAuthStatus;
  late MockGetProfile mockGetProfile;
  late MockCheckSplashVersion mockCheckSplashVersion;
  late MockCheckOnboardingStatus mockCheckOnboardingStatus;

  setUp(() {
    mockCheckAuthStatus = MockCheckAuthStatus();
    mockGetProfile = MockGetProfile();
    mockCheckSplashVersion = MockCheckSplashVersion();
    mockCheckOnboardingStatus = MockCheckOnboardingStatus();

    bloc = SplashBloc(
      checkAuthStatus: mockCheckAuthStatus,
      getProfile: mockGetProfile,
      checkAppVersion: mockCheckSplashVersion,
      checkOnboardingStatus: mockCheckOnboardingStatus,
    );

    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  const tVersionParams = Version(
    forceUpdate: false,
    ios: '1.0.0',
    android: '1.0.0',
    countries: [],
  );

  const tVersionForceParams = Version(
    forceUpdate: true,
    ios: '1.0.0',
    android: '1.0.0',
    countries: [],
  );

  group('SplashBloc', () {
    test('initial state is SplashInitial', () {
      expect(bloc.state, SplashInitial());
    });

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashForceUpdate] when version query returns forceUpdate=true',
      build: () {
        when(() => mockCheckSplashVersion(any()))
            .thenAnswer((_) async => const Right(tVersionForceParams));
        return bloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        SplashLoading(),
        SplashForceUpdate(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashAuthenticated] when authenticated',
      build: () {
        when(() => mockCheckSplashVersion(any()))
            .thenAnswer((_) async => const Right(tVersionParams));
        when(() => mockCheckAuthStatus(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        SplashLoading(),
        SplashAuthenticated(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashUnauthenticated] when unauthenticated but onboarding seen',
      build: () {
        when(() => mockCheckSplashVersion(any()))
            .thenAnswer((_) async => const Right(tVersionParams));
        when(() => mockCheckAuthStatus(any()))
            .thenAnswer((_) async => const Right(false));
        when(() => mockCheckOnboardingStatus(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        SplashLoading(),
        SplashUnauthenticated(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashNavigateToOnboarding] when unauthenticated and onboarding NOT seen',
      build: () {
        when(() => mockCheckSplashVersion(any()))
            .thenAnswer((_) async => const Right(tVersionParams));
        when(() => mockCheckAuthStatus(any()))
            .thenAnswer((_) async => const Right(false));
        when(() => mockCheckOnboardingStatus(any()))
            .thenAnswer((_) async => const Right(false));
        return bloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        SplashLoading(),
        SplashNavigateToOnboarding(),
      ],
    );

    blocTest<SplashBloc, SplashState>(
      'emits [SplashLoading, SplashError] when check version fails',
      build: () {
        when(() => mockCheckSplashVersion(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Version Error')));
        // Logic in bloc: if error, emit error and RETURN.
        return bloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        SplashLoading(),
        const SplashError(message: 'Version Error'),
      ],
    );
  });
}
