part of 'faq_bloc.dart';

abstract class FAQEvent extends Equatable {
  const FAQEvent();

  @override
  List<Object> get props => [];
}

class FAQLoadCategories extends FAQEvent {

  const FAQLoadCategories({
    this.initialCategoryName,
    this.initialCategoryIndex,
    this.type = 'FAQ',
  });
  final String? initialCategoryName;
  final int? initialCategoryIndex;
  final String type;

  @override
  List<Object> get props => [
        initialCategoryName ?? '',
        initialCategoryIndex ?? -1,
        type,
      ];
}

class FAQSelectCategory extends FAQEvent {

  const FAQSelectCategory(this.index);
  final int index;

  @override
  List<Object> get props => [index];
}

class FAQLoadData extends FAQEvent {

  const FAQLoadData({this.isRefresh = false, this.isLoadMore = false});
  final bool isRefresh;
  final bool isLoadMore;

  @override
  List<Object> get props => [isRefresh, isLoadMore];
}

class FAQToggleItem extends FAQEvent {

  const FAQToggleItem(this.index);
  final int index;

  @override
  List<Object> get props => [index];
}

class FAQSearch extends FAQEvent {

  const FAQSearch(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}
