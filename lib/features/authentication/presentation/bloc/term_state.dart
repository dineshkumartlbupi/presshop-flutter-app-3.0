abstract class TermsState {
  const TermsState();
}

class TermsInitial extends TermsState {
  const TermsInitial();
}

class TermsLoading extends TermsState {
  const TermsLoading();
}

class TermsLoaded extends TermsState {
  const TermsLoaded({required this.htmlContent}) : super();
  final String htmlContent;
}

class TermsError extends TermsState {
  const TermsError({required this.message}) : super();
  final String message;
}
