import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  
  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingSuccess extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError({required this.message});
  @override
  List<Object> get props => [message];
}
