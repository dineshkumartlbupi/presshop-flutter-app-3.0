import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';
import 'package:presshop/features/rating/domain/usecases/get_media_houses.dart';
import 'package:presshop/features/rating/domain/usecases/get_reviews.dart';
import 'package:presshop/core/error/failures.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final GetReviews getReviews;
  final GetMediaHouses getMediaHouses;

  RatingBloc({
    required this.getReviews,
    required this.getMediaHouses,
  }) : super(const RatingState()) {
    on<RatingLoadInitial>(_onLoadInitial);
    on<RatingLoadReviews>(_onLoadReviews);
    on<RatingTypeChanged>(_onTypeChanged);
    on<RatingFilterUpdated>(_onFilterUpdated);
  }

  Future<void> _onLoadInitial(
    RatingLoadInitial event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(status: RatingStatus.loading));

    // Load Media Houses first or parallel
    final mediaHouseResult = await getMediaHouses(NoParams());
    List<MediaHouse> mediaHouses = [];
    mediaHouseResult.fold(
        (l) => null, // Ignore failure for filter list or handle?
        (r) => mediaHouses = r);

    emit(state.copyWith(mediaHouses: mediaHouses));
    add(const RatingLoadReviews(isRefresh: true));
  }

  Future<void> _onLoadReviews(
    RatingLoadReviews event,
    Emitter<RatingState> emit,
  ) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    if (event.isRefresh) {
      emit(state.copyWith(
          status: RatingStatus.loading, reviews: [], hasReachedMax: false));
    }

    final offset = event.isRefresh ? 0 : state.reviews.length;
    final limit = 10;

    // Extract filter params
    final filters = state.filters;
    final String type = state.type;

    final result = await getReviews(GetReviewsParams(
      type: type,
      offset: offset,
      limit: limit,
      startDate: filters['startDate'],
      endDate: filters['endDate'],
      publicationId: filters['publicationId'],
      rating: filters['rating'],
      startRating: filters['startRating'],
      endRating: filters['endRating'],
    ));

    result.fold(
      (Failure failure) => emit(state.copyWith(
          status: RatingStatus.failure, errorMessage: failure.message)),
      (newReviews) {
        final allReviews = event.isRefresh
            ? newReviews
            : (List<Review>.from(state.reviews)..addAll(newReviews));

        emit(state.copyWith(
          status: RatingStatus.success,
          reviews: allReviews,
          hasReachedMax: newReviews.length < limit,
        ));
      },
    );
  }

  void _onTypeChanged(
    RatingTypeChanged event,
    Emitter<RatingState> emit,
  ) {
    if (state.type == event.type) return;
    emit(state.copyWith(type: event.type));
    add(const RatingLoadReviews(isRefresh: true));
  }

  void _onFilterUpdated(
    RatingFilterUpdated event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(filters: event.filters));
    add(const RatingLoadReviews(isRefresh: true));
  }
}
