part of 'faq_bloc.dart';

abstract class FAQEvent extends Equatable {
  const FAQEvent();

  @override
  List<Object> get props => [];
}

class FAQLoadCategories extends FAQEvent {
  final String? initialCategoryName;
  final int? initialCategoryIndex;

  const FAQLoadCategories({
    this.initialCategoryName,
    this.initialCategoryIndex,
  });

  @override
  List<Object> get props => [
        initialCategoryName ?? '',
        initialCategoryIndex ?? -1,
      ];
}

class FAQSelectCategory extends FAQEvent {
  final int index;

  const FAQSelectCategory(this.index);

  @override
  List<Object> get props => [index];
}

class FAQLoadData extends FAQEvent {
  final bool isRefresh;
  final bool isLoadMore;

  const FAQLoadData({this.isRefresh = false, this.isLoadMore = false});

  @override
  List<Object> get props => [isRefresh, isLoadMore];
}

class FAQToggleItem extends FAQEvent {
  final int index;

  const FAQToggleItem(this.index);

  @override
  List<Object> get props => [index];
}

class FAQSearch extends FAQEvent {
  final String query;

  const FAQSearch(this.query);

  @override
  List<Object> get props => [query];
}
