abstract class TermsEvent {}

class FetchTermsEvent extends TermsEvent {

  FetchTermsEvent({required this.type});
  final String type;
}
