import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_content_categories.dart';
import '../../domain/usecases/get_charities.dart';
import '../../domain/usecases/get_share_exclusive_price.dart';
import '../../../../core/usecases/usecase.dart';
import 'publish_event.dart';
import 'publish_state.dart';

class PublishBloc extends Bloc<PublishEvent, PublishState> {
  final GetContentCategories getContentCategories;
  final GetCharities getCharities;
  final GetShareExclusivePrice getShareExclusivePrice;

  PublishBloc({
    required this.getContentCategories,
    required this.getCharities,
    required this.getShareExclusivePrice,
  }) : super(const PublishState()) {
    on<LoadPublishDataEvent>(_onLoadPublishData);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<FetchCharitiesEvent>(_onFetchCharities);
    on<ToggleCharityEvent>(_onToggleCharity);
    on<SelectCharityEvent>(_onSelectCharity);
  }

  Future<void> _onLoadPublishData(LoadPublishDataEvent event, Emitter<PublishState> emit) async {
    emit(state.copyWith(status: PublishStatus.loading));
    
    // Fetch categories
    final failureOrCategories = await getContentCategories(NoParams());
    
    // Fetch prices
    final failureOrPrices = await getShareExclusivePrice(NoParams());

    // Combine results
    // Simpler sequential handling for now
    List<dynamic> results = [failureOrCategories, failureOrPrices];
    
    failureOrCategories.fold(
      (failure) => emit(state.copyWith(status: PublishStatus.failure, errorMessage: failure.message)),
      (categories) {
          // Select first by default if available?
          final selected = categories.isNotEmpty ? categories.first : null;
          emit(state.copyWith(categories: categories, selectedCategory: selected));
      }
    );

    failureOrPrices.fold(
       (failure) => null, // Ignore price error for now or handle
       (prices) => emit(state.copyWith(prices: prices))
    );
    
    if (state.status != PublishStatus.failure) {
        emit(state.copyWith(status: PublishStatus.loaded));
    }
  }

  void _onSelectCategory(SelectCategoryEvent event, Emitter<PublishState> emit) {
    final updatedCategories = state.categories.map((category) {
      return category.copyWith(selected: category.id == event.categoryId);
    }).toList();

    try {
      final selectedCategory = updatedCategories.firstWhere((c) => c.id == event.categoryId);
      emit(state.copyWith(
        categories: updatedCategories,
        selectedCategory: selectedCategory,
      ));
    } catch (_) {
      emit(state.copyWith(categories: updatedCategories));
    }
  }

  Future<void> _onFetchCharities(FetchCharitiesEvent event, Emitter<PublishState> emit) async {
      // Logic for pagination if needed
      final failureOrCharities = await getCharities(GetCharitiesParams(offset: event.offset, limit: event.limit));
      failureOrCharities.fold(
          (failure) => emit(state.copyWith(errorMessage: failure.message)),
          (charities) => emit(state.copyWith(charities: charities))
      );
  }

  void _onToggleCharity(ToggleCharityEvent event, Emitter<PublishState> emit) {
      emit(state.copyWith(isCharitySelected: event.isSelected));
  }

  void _onSelectCharity(SelectCharityEvent event, Emitter<PublishState> emit) {
      final updatedCharities = state.charities.map((c) {
        return c.copyWith(isSelectCharity: c.id == event.charityId);
      }).toList();
      emit(state.copyWith(charities: updatedCharities, isCharitySelected: true));
  }
}
