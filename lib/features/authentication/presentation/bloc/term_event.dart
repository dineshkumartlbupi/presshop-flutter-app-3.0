abstract class TermsEvent {}

class FetchTermsEvent extends TermsEvent {
  final String type;

  FetchTermsEvent({required this.type});
}
