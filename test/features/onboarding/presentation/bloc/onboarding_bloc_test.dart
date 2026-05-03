import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/authentication/domain/usecases/set_onboarding_seen.dart';
import 'package:presshop/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:presshop/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:presshop/features/onboarding/presentation/bloc/onboarding_state.dart';

class MockSetOnboardingSeen extends Mock implements SetOnboardingSeen {}

void main() {
  late OnboardingBloc bloc;
  late MockSetOnboardingSeen mockSetOnboardingSeen;

  setUp(() {
    mockSetOnboardingSeen = MockSetOnboardingSeen();
    bloc = OnboardingBloc(setOnboardingSeen: mockSetOnboardingSeen);
    registerFallbackValue(NoParams());
  });

  tearDown(() {
    bloc.close();
  });

  group('OnboardingBloc', () {
    test('initial state is OnboardingInitial', () {
      expect(bloc.state, OnboardingInitial());
    });

    blocTest<OnboardingBloc, OnboardingState>(
        'emits [OnboardingSuccess] when SetOnboardingSeen succeeds',
        build: () {
          when(() => mockSetOnboardingSeen(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(CompleteOnboarding()),
        expect: () => [
              OnboardingSuccess(),
            ],
        verify: (_) {
          verify(() => mockSetOnboardingSeen(any())).called(1);
        });

    blocTest<OnboardingBloc, OnboardingState>(
        'emits [OnboardingError] when SetOnboardingSeen fails',
        build: () {
          when(() => mockSetOnboardingSeen(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(CompleteOnboarding()),
        expect: () => [
              const OnboardingError(message: 'Failed to save status'),
            ],
        verify: (_) {
          verify(() => mockSetOnboardingSeen(any())).called(1);
        });
  });
}
