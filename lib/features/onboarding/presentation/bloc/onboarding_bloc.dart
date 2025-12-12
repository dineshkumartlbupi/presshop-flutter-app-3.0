import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../authentication/domain/usecases/set_onboarding_seen.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SetOnboardingSeen setOnboardingSeen;

  OnboardingBloc({
    required this.setOnboardingSeen,
  }) : super(OnboardingInitial()) {
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await setOnboardingSeen(NoParams());
    result.fold(
      (failure) => emit(const OnboardingError(message: "Failed to save status")),
      (_) => emit(OnboardingSuccess()),
    );
  }
}
