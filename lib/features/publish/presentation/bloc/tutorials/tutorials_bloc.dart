import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../domain/usecases/get_tutorial_categories.dart';
import '../../../domain/usecases/get_tutorial_videos.dart';
import '../../../domain/usecases/add_tutorial_view_count.dart';
import '../../../data/models/tutorials_model.dart';
import '../../../data/models/category_data_model.dart';

part 'tutorials_event.dart';
part 'tutorials_state.dart';

class TutorialsBloc extends Bloc<TutorialsEvent, TutorialsState> {
  final GetTutorialCategories getTutorialCategories;
  final GetTutorialVideos getTutorialVideos;
  final AddTutorialViewCount addTutorialViewCount;

  TutorialsBloc({
    required this.getTutorialCategories,
    required this.getTutorialVideos,
    required this.addTutorialViewCount,
  }) : super(const TutorialsState()) {
    on<TutorialsLoadCategories>(_onLoadCategories);
    on<TutorialsLoadVideos>(_onLoadVideos);
    on<TutorialsSelectCategory>(_onSelectCategory);
    on<TutorialsSearchVideos>(_onSearchVideos);
    on<TutorialsAddViewCount>(_onAddViewCount);
  }

  Future<void> _onLoadCategories(
    TutorialsLoadCategories event,
    Emitter<TutorialsState> emit,
  ) async {
    // Only load if empty or refresh needed.
    // Usually initial load.
    emit(state.copyWith(status: TutorialsStatus.loading));
    final result = await getTutorialCategories(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: TutorialsStatus.failure, errorMessage: failure.message)),
      (categories) {
        if (categories.isNotEmpty) {
          // Select first category
          var updatedCategories = List<CategoryDataModel>.from(categories);
          updatedCategories[0] = updatedCategories[0].copyWith(selected: true);

          emit(state.copyWith(
            categories: updatedCategories,
            selectedCategoryIndex: 0,
            // After loading categories, load videos for first category
          ));
          add(TutorialsLoadVideos(category: updatedCategories[0].name));
        } else {
          emit(state.copyWith(status: TutorialsStatus.success, categories: []));
        }
      },
    );
  }

  Future<void> _onLoadVideos(
    TutorialsLoadVideos event,
    Emitter<TutorialsState> emit,
  ) async {
    if (event.isLoadMore) {
      if (state.hasReachedMax) return;
      // emit loading more? usually just keep ui showing loading at bottom
    } else {
      if (!event.isRefresh)
        emit(state.copyWith(status: TutorialsStatus.loading));
    }

    int offset = event.isRefresh || (!event.isLoadMore) ? 0 : state.offset + 10;

    final result = await getTutorialVideos(GetTutorialVideosParams(
      category: event.category,
      offset: offset,
      limit: 10,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
          status: TutorialsStatus.failure, errorMessage: failure.message)),
      (newVideos) {
        List<TutorialsModel> allVideos = [];
        if (event.isRefresh || !event.isLoadMore) {
          allVideos = newVideos;
        } else {
          allVideos = List.of(state.videos)..addAll(newVideos);
        }

        emit(state.copyWith(
          status: TutorialsStatus.success,
          videos: allVideos,
          offset: offset,
          hasReachedMax: newVideos.length < 10,
        ));
      },
    );
  }

  Future<void> _onSelectCategory(
    TutorialsSelectCategory event,
    Emitter<TutorialsState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.categories.length) return;
    if (state.selectedCategoryIndex == event.index) return;

    List<CategoryDataModel> updatedCategories = List.from(state.categories);
    // Deselect old
    updatedCategories[state.selectedCategoryIndex] =
        updatedCategories[state.selectedCategoryIndex]
            .copyWith(selected: false);
    // Select new
    updatedCategories[event.index] =
        updatedCategories[event.index].copyWith(selected: true);

    emit(state.copyWith(
      selectedCategoryIndex: event.index,
      categories: updatedCategories,
      videos: [], // Clear old videos
      status: TutorialsStatus.loading,
      offset: 0,
      hasReachedMax: false,
    ));

    add(TutorialsLoadVideos(category: updatedCategories[event.index].name));
  }

  void _onSearchVideos(
    TutorialsSearchVideos event,
    Emitter<TutorialsState> emit,
  ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(isSearch: false, searchResults: []));
    } else {
      final results = state.videos
          .where((element) => element.description
              .toLowerCase()
              .contains(event.query.toLowerCase()))
          .toList();
      emit(state.copyWith(isSearch: true, searchResults: results));
    }
  }

  Future<void> _onAddViewCount(
    TutorialsAddViewCount event,
    Emitter<TutorialsState> emit,
  ) async {
    await addTutorialViewCount(
        AddTutorialViewCountParams(tutorialId: event.tutorialId));
    // No state update needed usually, just fire and forget or update local count?
    // Screen implementation didn't update local count, just navigated.
  }
}
