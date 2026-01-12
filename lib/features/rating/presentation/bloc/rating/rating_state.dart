part of 'rating_bloc.dart';

enum RatingStatus { initial, loading, success, failure }

class RatingState extends Equatable {
  final RatingStatus status;
  final List<Review> reviews;
  final List<MediaHouse> mediaHouses;
  final bool hasReachedMax;
  final String errorMessage;
  final String type; // 'Received' or 'Given'
  final Map<String, dynamic> filters; // Store filter params

  const RatingState({
    this.status = RatingStatus.initial,
    this.reviews = const [],
    this.mediaHouses = const [],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.type = 'Received',
    this.filters = const {},
  });

  RatingState copyWith({
    RatingStatus? status,
    List<Review>? reviews,
    List<MediaHouse>? mediaHouses,
    bool? hasReachedMax,
    String? errorMessage,
    String? type,
    Map<String, dynamic>? filters,
  }) {
    return RatingState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      mediaHouses: mediaHouses ?? this.mediaHouses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object> get props => [
        status,
        reviews,
        mediaHouses,
        hasReachedMax,
        errorMessage,
        type,
        filters,
      ];
}
