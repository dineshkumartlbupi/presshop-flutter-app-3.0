import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/rating/domain/entities/media_house.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';
import 'package:presshop/features/rating/domain/usecases/get_media_houses.dart';
import 'package:presshop/features/rating/domain/usecases/get_reviews.dart';
import 'package:presshop/features/rating/presentation/bloc/rating/rating_bloc.dart';

class MockGetReviews extends Mock implements GetReviews {}

class MockGetMediaHouses extends Mock implements GetMediaHouses {}

void main() {
  late RatingBloc bloc;
  late MockGetReviews mockGetReviews;
  late MockGetMediaHouses mockGetMediaHouses;

  setUp(() {
    mockGetReviews = MockGetReviews();
    mockGetMediaHouses = MockGetMediaHouses();
    bloc = RatingBloc(
      getReviews: mockGetReviews,
      getMediaHouses: mockGetMediaHouses,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(
        const GetReviewsParams(type: 'Received', offset: 0, limit: 10));
  });

  tearDown(() {
    bloc.close();
  });

  const tMediaHouses = [
    MediaHouse(id: '1', name: 'BBC', profileImage: 'img'),
  ];

  const tReviews = [
    Review(
      id: '1',
      newsName: 'News',
      image: 'img',
      dateTime: '2023-01-01',
      date: '2023-01-01',
      time: '12:00',
      ratingValue: 5.0,
      review: 'Great',
      senderType: 'MediaHouse',
      from: 'BBC',
      to: 'Me',
      hopperImage: 'img',
      userName: 'User',
      totalEarning: '100',
      hopperCreatedAt: '2023',
      featureList: [],
    )
  ];

  group('RatingBloc', () {
    test('initial state is correct', () {
      expect(bloc.state.status, RatingStatus.initial);
    });

    group('RatingLoadInitial', () {
      blocTest<RatingBloc, RatingState>(
        'emits [mediaHouses loaded, loading reviews, success reviews] when success',
        build: () {
          when(() => mockGetMediaHouses(any()))
              .thenAnswer((_) async => const Right(tMediaHouses));
          when(() => mockGetReviews(any()))
              .thenAnswer((_) async => const Right(tReviews));
          return bloc;
        },
        act: (bloc) => bloc.add(RatingLoadInitial()),
        expect: () => [
          const RatingState(status: RatingStatus.loading),
          const RatingState(
              status: RatingStatus.loading, mediaHouses: tMediaHouses),
          const RatingState(
            status: RatingStatus.success,
            mediaHouses: tMediaHouses,
            reviews: tReviews,
            hasReachedMax: true,
          ),
        ],
      );
    });

    group('RatingLoadReviews', () {
      blocTest<RatingBloc, RatingState>(
        'emits [loading, success] when refresh',
        build: () {
          when(() => mockGetReviews(any()))
              .thenAnswer((_) async => const Right(tReviews));
          return bloc;
        },
        act: (bloc) => bloc.add(const RatingLoadReviews(isRefresh: true)),
        expect: () => [
          const RatingState(
              status: RatingStatus.loading, reviews: [], hasReachedMax: false),
          const RatingState(
              status: RatingStatus.success,
              reviews: tReviews,
              hasReachedMax: true),
        ],
      );

      blocTest<RatingBloc, RatingState>(
        'emits [success] when load more',
        seed: () =>
            const RatingState(status: RatingStatus.success, reviews: tReviews),
        build: () {
          when(() => mockGetReviews(any())).thenAnswer(
              (_) async => const Right([])); // Empty result -> reached max
          return bloc;
        },
        act: (bloc) => bloc.add(const RatingLoadReviews(isLoadMore: true)),
        expect: () => [
          const RatingState(
              status: RatingStatus.success,
              reviews: tReviews,
              hasReachedMax: true),
        ],
      );
    });

    group('RatingTypeChanged', () {
      blocTest<RatingBloc, RatingState>(
        'emits [type updated] and reloads',
        build: () {
          when(() => mockGetReviews(any()))
              .thenAnswer((_) async => const Right(tReviews));
          return bloc;
        },
        act: (bloc) => bloc.add(const RatingTypeChanged('Given')),
        expect: () => [
          const RatingState(type: 'Given'),
          const RatingState(
              type: 'Given',
              status: RatingStatus.loading,
              reviews: [],
              hasReachedMax: false),
          const RatingState(
              type: 'Given',
              status: RatingStatus.success,
              reviews: tReviews,
              hasReachedMax: true),
        ],
      );
    });
  });
}
