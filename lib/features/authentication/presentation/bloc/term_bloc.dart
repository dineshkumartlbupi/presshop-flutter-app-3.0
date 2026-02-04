import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/data/repositories/term_repository.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_state.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {

  TermsBloc(this.repository) : super(TermsInitial()) {
    on<FetchTermsEvent>((event, emit) async {
      emit(TermsLoading());

      try {
        final response = await repository.fetchTerms(event.type);

        final String htmlContent = event.type == "privacy_policy"
            ? response.data.privacyPolicy.description
            : response.data.termAndCond.description;

        emit(TermsLoaded(htmlContent: htmlContent));
      } catch (e) {
        emit(TermsError(message: e.toString()));
      }
    });
  }
  final TermsRepository repository;
}
