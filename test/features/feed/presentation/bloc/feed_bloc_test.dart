import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/feed/domain/entities/feed.dart';
import 'package:presshop/features/feed/domain/usecases/get_feeds.dart';
import 'package:presshop/features/feed/domain/usecases/toggle_feed_interaction.dart';
import 'package:presshop/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:presshop/features/feed/presentation/bloc/feed_event.dart';
import 'package:presshop/features/feed/presentation/bloc/feed_state.dart';

class MockGetFeeds extends Mock implements GetFeeds {}

class MockToggleFeedInteraction extends Mock implements ToggleFeedInteraction {}

class FakeGetFeedsParams extends Fake implements GetFeedsParams {}

class FakeToggleFeedInteractionParams extends Fake
    implements ToggleFeedInteractionParams {}

void main() {
  late FeedBloc bloc;
  late MockGetFeeds mockGetFeeds;
  late MockToggleFeedInteraction mockToggleFeedInteraction;

  setUpAll(() {
    registerFallbackValue(FakeGetFeedsParams());
    registerFallbackValue(FakeToggleFeedInteractionParams());
  });

  setUp(() {
    mockGetFeeds = MockGetFeeds();
    mockToggleFeedInteraction = MockToggleFeedInteraction();
    bloc = FeedBloc(
      getFeeds: mockGetFeeds,
      toggleFeedInteraction: mockToggleFeedInteraction,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tFeedId = 'feed_1';
  const tFeed = Feed(
    id: tFeedId,
    heading: 'Heading',
    description: 'Desc',
    location: 'Loc',
    categoryName: 'Cat',
    askPrice: '100',
    displayPrice: '100',
    displayCurrency: 'USD',
    viewCount: 10,
    offerCount: 5,
    createdAt: '2023-01-01',
    timeAgo: '1h',
    feedImage: 'img.jpg',
    status: 'active',
    isFavourite: false,
    isLiked: false,
    isEmoji: false,
    isClap: false,
    contentList: [],
    type: 'image',
    isDraft: false,
    userId: 'u1',
    saleStatus: 'unsold',
    paidStatus: 'unpaid',
  );

  final tFeeds = [tFeed];

  group('FetchFeeds', () {
    test('initial state is correct', () {
      expect(bloc.state, const FeedState());
    });

    blocTest<FeedBloc, FeedState>(
      'emits [loading, success] when data is fetched successfully',
      build: () {
        when(() => mockGetFeeds(any())).thenAnswer((_) async => Right(tFeeds));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchFeeds()),
      expect: () => [
        isA<FeedState>().having((s) => s.status, 'status', FeedStatus.loading),
        isA<FeedState>()
            .having((s) => s.status, 'status', FeedStatus.success)
            .having((s) => s.feeds, 'feeds', tFeeds)
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [loading, failure] when fetching fails',
      build: () {
        when(() => mockGetFeeds(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchFeeds()),
      expect: () => [
        isA<FeedState>().having((s) => s.status, 'status', FeedStatus.loading),
        isA<FeedState>()
            .having((s) => s.status, 'status', FeedStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('Error'))
      ],
    );
  });

  group('Toggle Interactions (Optimistic Update)', () {
    // For interactions, we need the bloc to have some feeds first
    // We can seed the state with feeds using seed parameter.

    blocTest<FeedBloc, FeedState>('optimistically updates isLiked to true',
        build: () {
          when(() => mockToggleFeedInteraction(any()))
              .thenAnswer((_) async => const Right(true)); // Fixed return type
          return bloc;
        },
        seed: () => FeedState(status: FeedStatus.success, feeds: [tFeed]),
        act: (bloc) =>
            bloc.add(const ToggleLikeFeed(id: tFeedId, isLiked: true)),
        expect: () => [
              isA<FeedState>()
                  .having((s) => s.feeds.first.isLiked, 'isLiked', true)
                  .having(
                      (s) => s.feeds.first.isFavourite, 'isFavourite', false)
            ],
        verify: (_) {
          verify(() => mockToggleFeedInteraction(any())).called(1);
        });

    blocTest<FeedBloc, FeedState>(
      'reverts update if API fails',
      build: () {
        when(() => mockToggleFeedInteraction(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Failed')));
        return bloc;
      },
      seed: () => FeedState(status: FeedStatus.success, feeds: [tFeed]),
      act: (bloc) => bloc.add(const ToggleLikeFeed(id: tFeedId, isLiked: true)),
      expect: () => [
        // First optimistic update
        isA<FeedState>().having((s) => s.feeds.first.isLiked, 'isLiked', true),
        // Then revert
        isA<FeedState>()
            .having((s) => s.feeds.first.isLiked, 'isLiked', false)
            .having((s) => s.errorMessage, 'error', 'Interaction failed')
      ],
    );
  });
}
