import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/data/repositories/term_repository.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class TermsBloc extends Bloc<TermsEvent, TermsState> {
  TermsBloc(this.repository, this.sharedPreferences) : super(TermsInitial()) {
    on<FetchTermsEvent>((event, emit) async {
      final cacheKey = "${SharedPreferencesKeys.termsCachePrefix}${event.type}";
      final cachedContent = sharedPreferences.getString(cacheKey);

      bool emittedFromCache = false;
      if (cachedContent != null && cachedContent.isNotEmpty) {
        emit(TermsLoaded(htmlContent: cachedContent));
        emittedFromCache = true;
      }

      if (!emittedFromCache) {
        emit(TermsLoading());
      }

      try {
        final response = await repository.fetchTerms(event.type);

        final String htmlContent = event.type == "privacy_policy"
            ? response.data.privacyPolicy.description
            : response.data.termAndCond.description;

        if (htmlContent.isNotEmpty) {
          sharedPreferences.setString(cacheKey, htmlContent);
          emit(TermsLoaded(htmlContent: htmlContent));
        } else if (!emittedFromCache) {
          emit(const TermsLoaded(htmlContent: ""));
        }
      } catch (e) {
        if (!emittedFromCache) {
          emit(TermsError(message: e.toString()));
        }
      }
    });
  }
  final TermsRepository repository;
  final SharedPreferences sharedPreferences;
}
