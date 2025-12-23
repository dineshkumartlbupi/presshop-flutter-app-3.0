abstract class TermsState {}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final String htmlContent;

  TermsLoaded({required this.htmlContent});
}

class TermsError extends TermsState {
  final String message;

  TermsError({required this.message});
}
