part of 'tutorials_bloc.dart';

enum TutorialsStatus { initial, loading, success, failure, loadingMore }

class TutorialsState extends Equatable {

  const TutorialsState({
    this.status = TutorialsStatus.initial,
    this.categories = const [],
    this.videos = const [],
    this.searchResults = const [],
    this.selectedCategoryIndex = 0,
    this.errorMessage = "",
    this.isSearch = false,
    this.hasReachedMax = false,
    this.offset = 0,
  });
  final TutorialsStatus status;
  final List<CategoryDataModel> categories;
  final List<TutorialsModel> videos;
  final List<TutorialsModel> searchResults;
  final int selectedCategoryIndex;
  final String errorMessage;
  final bool isSearch;
  final bool hasReachedMax;
  final int offset;

  TutorialsState copyWith({
    TutorialsStatus? status,
    List<CategoryDataModel>? categories,
    List<TutorialsModel>? videos,
    List<TutorialsModel>? searchResults,
    int? selectedCategoryIndex,
    String? errorMessage,
    bool? isSearch,
    bool? hasReachedMax,
    int? offset,
  }) {
    return TutorialsState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      videos: videos ?? this.videos,
      searchResults: searchResults ?? this.searchResults,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearch: isSearch ?? this.isSearch,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object> get props => [
        status,
        categories,
        videos,
        searchResults,
        selectedCategoryIndex,
        errorMessage,
        isSearch,
        hasReachedMax,
        offset
      ];
}
