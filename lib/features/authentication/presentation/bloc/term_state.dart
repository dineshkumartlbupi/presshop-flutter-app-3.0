abstract class TermsState {}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {

  TermsLoaded({required this.htmlContent});
  final String htmlContent;
}

class TermsError extends TermsState {

  TermsError({required this.message});
  final String message;
}
