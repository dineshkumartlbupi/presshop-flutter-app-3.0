import 'package:equatable/equatable.dart';
import '../../domain/entities/content_category.dart';
import '../../domain/entities/charity.dart';

enum PublishStatus { initial, loading, loaded, submitting, success, failure }

class PublishState extends Equatable {
  final PublishStatus status;
  final List<ContentCategory> categories;
  final List<Charity> charities;
  final Map<String, String> prices;
  final String errorMessage;
  final ContentCategory? selectedCategory;
  final bool isCharitySelected;

  const PublishState({
    this.status = PublishStatus.initial,
    this.categories = const [],
    this.charities = const [],
    this.prices = const {},
    this.errorMessage = '',
    this.selectedCategory,
    this.isCharitySelected = false,
  });

  PublishState copyWith({
    PublishStatus? status,
    List<ContentCategory>? categories,
    List<Charity>? charities,
    Map<String, String>? prices,
    String? errorMessage,
    ContentCategory? selectedCategory,
    bool? isCharitySelected,
  }) {
    return PublishState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      charities: charities ?? this.charities,
      prices: prices ?? this.prices,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isCharitySelected: isCharitySelected ?? this.isCharitySelected,
    );
  }

  @override
  List<Object?> get props => [status, categories, charities, prices, errorMessage, selectedCategory, isCharitySelected];
}
