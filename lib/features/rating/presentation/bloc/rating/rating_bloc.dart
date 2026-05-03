import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';
import 'package:presshop/features/rating/domain/usecases/get_media_houses.dart';
import 'package:presshop/features/rating/domain/usecases/get_reviews.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc({
    required this.getReviews,
    required this.getMediaHouses,
  }) : super(const RatingState()) {
    on<RatingLoadInitial>(_onLoadInitial);
    on<RatingLoadReviews>(_onLoadReviews);
    on<RatingTypeChanged>(_onTypeChanged);
    on<RatingFilterUpdated>(_onFilterUpdated);
    on<RatingMediaHousesUpdated>(_onMediaHousesUpdated);
  }
  final GetReviews getReviews;
  final GetMediaHouses getMediaHouses;

  Future<void> _onLoadInitial(
    RatingLoadInitial event,
    Emitter<RatingState> emit,
  ) async {
    final cacheBox = Hive.box('sync_cache');

    // 1. Load Media Houses cache
    final cachedMediaHouses = cacheBox.get('media_houses');
    List<MediaHouse> mediaHouses = [];
    if (cachedMediaHouses != null && cachedMediaHouses is List) {
      try {
        mediaHouses = cachedMediaHouses
            .map((e) => MediaHouse(
                  id: (e['id'] ?? '').toString(),
                  name: (e['name'] ?? '').toString(),
                  profileImage: (e['profile_image'] ?? '').toString(),
                ))
            .toList();
      } catch (e) {
        debugPrint("Error loading media houses from cache: $e");
      }
    }

    // 2. Load Reviews cache
    final String type = state.type;
    final String reviewsCacheKey = 'reviews_$type';
    final cachedReviewsData = cacheBox.get(reviewsCacheKey);
    List<Review> reviews = [];
    if (cachedReviewsData != null && cachedReviewsData is List) {
      try {
        reviews = cachedReviewsData
            .map((e) => Review(
                  id: e['id'] ?? '',
                  newsName: e['newsName'] ?? '',
                  image: e['image'] ?? '',
                  dateTime: e['dateTime'] ?? '',
                  date: e['date'] ?? '',
                  time: e['time'] ?? '',
                  ratingValue: (e['ratingValue'] ?? 0.0).toDouble(),
                  review: e['review'] ?? '',
                  senderType: e['senderType'] ?? '',
                  from: e['from'] ?? '',
                  to: e['to'] ?? '',
                  hopperImage: e['hopperImage'] ?? '',
                  userName: e['userName'] ?? '',
                  totalEarning: e['totalEarning'] ?? '',
                  hopperCreatedAt: e['hopperCreatedAt'] ?? '',
                  featureList: List<String>.from(e['featureList'] ?? []),
                ))
            .toList();
      } catch (e) {
        debugPrint("Error loading reviews from cache: $e");
      }
    }

    // 3. Emit cache immediately
    if (mediaHouses.isNotEmpty || reviews.isNotEmpty) {
      emit(state.copyWith(
        status:
            reviews.isNotEmpty ? RatingStatus.success : RatingStatus.loading,
        mediaHouses: mediaHouses,
        reviews: reviews,
      ));
    }

    // 4. Update status to loading if absolutely empty or we only have media houses
    if (state.status == RatingStatus.initial) {
      emit(state.copyWith(status: RatingStatus.loading));
    }

    // 5. Fetch fresh Media Houses (Silent background)
    getMediaHouses(NoParams()).then((mediaHouseResult) {
      mediaHouseResult.fold(
        (l) => null,
        (r) {
          cacheBox.put('media_houses', r.map((e) => e.toJson()).toList());
          add(RatingMediaHousesUpdated(mediaHouses: r));
        },
      );
    });

    // 6. Trigger background reviews update
    add(const RatingLoadReviews(isRefresh: true));
  }

  Future<void> _onLoadReviews(
    RatingLoadReviews event,
    Emitter<RatingState> emit,
  ) async {
    if (state.hasReachedMax && event.isLoadMore) return;

    final cacheBox = Hive.box('sync_cache');
    final String type = state.type;
    final String cacheKey = 'reviews_$type';

    if (event.isRefresh) {
      final cachedData = cacheBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        final cachedReviews = cachedData
            .map((e) => Review(
                  id: e['id'] ?? '',
                  newsName: e['newsName'] ?? '',
                  image: e['image'] ?? '',
                  dateTime: e['dateTime'] ?? '',
                  date: e['date'] ?? '',
                  time: e['time'] ?? '',
                  ratingValue: (e['ratingValue'] ?? 0.0).toDouble(),
                  review: e['review'] ?? '',
                  senderType: e['senderType'] ?? '',
                  from: e['from'] ?? '',
                  to: e['to'] ?? '',
                  hopperImage: e['hopperImage'] ?? '',
                  userName: e['userName'] ?? '',
                  totalEarning: e['totalEarning'] ?? '',
                  hopperCreatedAt: e['hopperCreatedAt'] ?? '',
                  featureList: List<String>.from(e['featureList'] ?? []),
                ))
            .toList();
        if (cachedReviews.isNotEmpty) {
          emit(state.copyWith(
              status: RatingStatus.success, reviews: cachedReviews));
        }
      }
      if (state.reviews.isEmpty) {
        emit(state.copyWith(
            status: RatingStatus.loading, reviews: [], hasReachedMax: false));
      }
    }

    final offset = event.isRefresh ? 0 : state.reviews.length;
    final limit = 10;
    final filters = state.filters;

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
      (failure) {
        if (state.reviews.isEmpty) {
          emit(state.copyWith(
              status: RatingStatus.failure, errorMessage: failure.message));
        }
      },
      (newReviews) {
        final allReviews = event.isRefresh
            ? newReviews
            : (List<Review>.from(state.reviews)..addAll(newReviews));

        if (event.isRefresh) {
          cacheBox.put(cacheKey, newReviews.map((e) => e.toJson()).toList());
        }

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

  void _onMediaHousesUpdated(
    RatingMediaHousesUpdated event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(mediaHouses: event.mediaHouses));
  }
}
