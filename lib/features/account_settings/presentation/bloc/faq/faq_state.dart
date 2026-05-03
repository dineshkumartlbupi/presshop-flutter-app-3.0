part of 'faq_bloc.dart';

enum FAQStatus { initial, loading, success, failure }

class FAQState extends Equatable {

  const FAQState({
    this.status = FAQStatus.initial,
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.items = const [],
    this.allItems = const [],
    this.searchQuery = '',
    this.errorMessage = '',
  });
  final FAQStatus status;
  final List<ContentCategory> categories;
  final int selectedCategoryIndex;
  final List<FAQ> items; // Items to display (filtered or all)
  final List<FAQ> allItems; // All items for the category (for searching)
  final String searchQuery;
  final String errorMessage;

  FAQState copyWith({
    FAQStatus? status,
    List<ContentCategory>? categories,
    int? selectedCategoryIndex,
    List<FAQ>? items,
    List<FAQ>? allItems,
    String? searchQuery,
    String? errorMessage,
  }) {
    return FAQState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      items: items ?? this.items,
      allItems: allItems ?? this.allItems,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        categories,
        selectedCategoryIndex,
        items,
        allItems,
        searchQuery,
        errorMessage,
      ];
}
