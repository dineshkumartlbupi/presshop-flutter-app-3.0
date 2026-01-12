import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../../publish/domain/entities/content_category.dart';
import '../../../domain/entities/faq.dart';
import '../../../domain/usecases/get_faqs.dart';
import '../../../domain/usecases/get_price_tips.dart';
import '../../../domain/usecases/get_faq_categories.dart';

part 'faq_event.dart';
part 'faq_state.dart';

class FAQBloc extends Bloc<FAQEvent, FAQState> {
  final GetFAQs getFAQs;
  final GetPriceTips getPriceTips;
  final GetFAQCategories getFAQCategories;

  FAQBloc({
    required this.getFAQs,
    required this.getPriceTips,
    required this.getFAQCategories,
  }) : super(const FAQState()) {
    on<FAQLoadCategories>(_onLoadCategories);
    on<FAQSelectCategory>(_onSelectCategory);
    on<FAQLoadData>(_onLoadData);
    on<FAQToggleItem>(_onToggleItem);
    on<FAQSearch>(_onSearch);
  }

  Future<void> _onLoadCategories(
    FAQLoadCategories event,
    Emitter<FAQState> emit,
  ) async {
    emit(state.copyWith(status: FAQStatus.loading));
    final result = await getFAQCategories(NoParams());

    result.fold(
      (Failure failure) => emit(state.copyWith(
          status: FAQStatus.failure, errorMessage: failure.message)),
      (categories) {
        if (categories.isNotEmpty) {
          var updatedCategories = List<ContentCategory>.from(categories);

          int selectedIndex = 0;

          if (event.initialCategoryIndex != null &&
              event.initialCategoryIndex! >= 0 &&
              event.initialCategoryIndex! < updatedCategories.length) {
            selectedIndex = event.initialCategoryIndex!;
          } else if (event.initialCategoryName != null &&
              event.initialCategoryName!.isNotEmpty) {
            final index = updatedCategories.indexWhere((c) =>
                c.name.toLowerCase() ==
                event.initialCategoryName!.toLowerCase());
            if (index != -1) {
              selectedIndex = index;
            } else if (event.initialCategoryName!.contains("benefits")) {
              // Fallback for benefits if exact name not found, try last like original code?
              // Original code: if benefits not empty, select last. name contains "benefits"?
              // Let's assume passed name is correct or we use index.
              // If "benefits" logic is needed, caller should pass index or name.
            }
          }

          // Mark selected
          for (int i = 0; i < updatedCategories.length; i++) {
            updatedCategories[i] =
                updatedCategories[i].copyWith(selected: i == selectedIndex);
          }

          emit(state.copyWith(
            categories: updatedCategories,
            selectedCategoryIndex: selectedIndex,
            status: FAQStatus.loading, // Keep loading for data fetch
          ));
          add(const FAQLoadData());
        } else {
          emit(state.copyWith(status: FAQStatus.success, categories: []));
        }
      },
    );
  }

  Future<void> _onSelectCategory(
    FAQSelectCategory event,
    Emitter<FAQState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.categories.length) return;
    if (state.selectedCategoryIndex == event.index) return;

    List<ContentCategory> updatedCategories = List.from(state.categories);
    updatedCategories[state.selectedCategoryIndex] =
        updatedCategories[state.selectedCategoryIndex]
            .copyWith(selected: false);
    updatedCategories[event.index] =
        updatedCategories[event.index].copyWith(selected: true);

    emit(state.copyWith(
      selectedCategoryIndex: event.index,
      categories: updatedCategories,
      status: FAQStatus.loading,
      items: [],
      allItems: [],
      searchQuery: '',
    ));

    add(const FAQLoadData());
  }

  Future<void> _onLoadData(
    FAQLoadData event,
    Emitter<FAQState> emit,
  ) async {
    if (state.categories.isEmpty) return;
    final category = state.categories[state.selectedCategoryIndex];
    if (!event.isRefresh) emit(state.copyWith(status: FAQStatus.loading));

    Either<Failure, List<FAQ>> result;

    if (category.name.toLowerCase().contains("price tips")) {
      result = await getPriceTips(GetPriceTipsParams(
        category: category.name,
        offset: 0,
        limit: 1000,
      ));
    } else {
      result = await getFAQs(GetFAQsParams(
        category: category.name,
        offset: 0,
        limit: 1000,
      ));
    }

    result.fold(
      (Failure failure) => emit(state.copyWith(
          status: FAQStatus.failure, errorMessage: failure.message)),
      (items) {
        emit(state.copyWith(
          status: FAQStatus.success,
          items: items,
          allItems: items,
        ));
      },
    );
  }

  void _onToggleItem(
    FAQToggleItem event,
    Emitter<FAQState> emit,
  ) {
    if (event.index < 0 || event.index >= state.items.length) return;

    List<FAQ> updatedItems = List.from(state.items);
    updatedItems[event.index] = updatedItems[event.index]
        .copyWith(selected: !updatedItems[event.index].selected);

    emit(state.copyWith(items: updatedItems));
  }

  void _onSearch(
    FAQSearch event,
    Emitter<FAQState> emit,
  ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        searchQuery: '',
        items: state.allItems,
      ));
    } else {
      final results = state.allItems.where((item) {
        return item.question.toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      emit(state.copyWith(
        searchQuery: event.query,
        items: results,
      ));
    }
  }
}
