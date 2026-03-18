import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/domain/usecases/get_aggregated_news.dart';
import 'package:presshop/features/news/domain/usecases/get_comments.dart';
import 'package:presshop/features/news/domain/usecases/get_news_detail.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:presshop/features/news/data/datasources/news_socket_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetAggregatedNews extends Mock implements GetAggregatedNews {}

class MockGetNewsDetail extends Mock implements GetNewsDetail {}

class MockGetComments extends Mock implements GetComments {}

class MockSocketService extends Mock implements NewsSocketDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NewsBloc bloc;
  late MockGetAggregatedNews mockGetAggregatedNews;
  late MockGetNewsDetail mockGetNewsDetail;
  late MockGetComments mockGetComments;
  late MockSocketService mockSocketService;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(const GetAggregatedNewsParams(lat: 0, lng: 0, km: 0));
    registerFallbackValue(const GetNewsDetailParams(id: ''));
    registerFallbackValue(const GetCommentsParams(contentId: ''));
  });

  setUp(() {
    mockGetAggregatedNews = MockGetAggregatedNews();
    mockGetNewsDetail = MockGetNewsDetail();
    mockGetComments = MockGetComments();
    mockSocketService = MockSocketService();
    mockSharedPreferences = MockSharedPreferences();

    bloc = NewsBloc(
      getAggregatedNews: mockGetAggregatedNews,
      getNewsDetail: mockGetNewsDetail,
      getComments: mockGetComments,
      newsSocketDataSource: mockSocketService,
      sharedPreferences: mockSharedPreferences,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tNews = News(id: '1', title: 'Test News', description: 'Description');
  // const tComment = Comment(
  //   id: 'c1',
  //   contentId: '1',
  //   userId: 'u1',
  //   comment: 'Test Comment',
  //   createdAt: '2023-01-01',
  // );

  group('GetAggregatedNewsEvent', () {
    const tLat = 51.5;
    const tLng = -0.12;
    const tKm = 10.0;

    blocTest<NewsBloc, NewsState>(
      'emits [isLoading: true, newsList: [tNews]] when successful',
      build: () {
        when(() => mockGetAggregatedNews(any()))
            .thenAnswer((_) async => const Right([tNews]));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const GetAggregatedNewsEvent(lat: tLat, lng: tLng, km: tKm)),
      expect: () => [
        const NewsState(isLoading: true),
        const NewsState(isLoading: false, newsList: [tNews]),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'emits [isLoading: true, isProcessing: true] when status is 202',
      build: () {
        when(() => mockGetAggregatedNews(any())).thenAnswer(
            (_) async => const Left(ProcessingFailure(message: 'Processing')));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const GetAggregatedNewsEvent(lat: tLat, lng: tLng, km: tKm)),
      expect: () => [
        const NewsState(isLoading: true),
        const NewsState(isLoading: false, isProcessing: true, newsList: []),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'emits [isLoading: true, errorMessage] when failure occurs',
      build: () {
        when(() => mockGetAggregatedNews(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const GetAggregatedNewsEvent(lat: tLat, lng: tLng, km: tKm)),
      expect: () => [
        const NewsState(isLoading: true),
        const NewsState(isLoading: false, errorMessage: 'Failed to fetch news'),
      ],
    );
  });

  group('GetNewsDetailEvent', () {
    const tId = '1';

    blocTest<NewsBloc, NewsState>(
      'emits [isLoading: true, selectedNews: tNews] when successful',
      build: () {
        when(() => mockGetNewsDetail(any()))
            .thenAnswer((_) async => const Right(tNews));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetNewsDetailEvent(id: tId)),
      expect: () => [
        const NewsState(isLoading: true),
        const NewsState(isLoading: false, selectedNews: tNews),
      ],
    );
  });

  group('ToggleNewsLikeEvent', () {
    const tContentId = '1';

    blocTest<NewsBloc, NewsState>(
      'optimistically updates newsList and triggers socket like',
      build: () {
        when(() => mockSharedPreferences.getString(any())).thenReturn('user1');
        when(() => mockSocketService.likeNews(
              userId: any(named: 'userId'),
              contentId: any(named: 'contentId'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => const NewsState(newsList: [tNews]),
      act: (bloc) => bloc.add(const ToggleNewsLikeEvent(contentId: tContentId)),
      expect: () => [
        isA<NewsState>().having((s) => s.newsList[0].isLiked, 'isLiked', true),
      ],
      verify: (_) {
        verify(() => mockSocketService.likeNews(
            userId: 'user1', contentId: tContentId)).called(1);
      },
    );
  });

  group('OnNewsLikeUpdatedEvent', () {
    final tLikeData = {
      'contentId': '1',
      'total_likes': '10',
      'is_liked': true,
    };

    blocTest<NewsBloc, NewsState>(
      'updates newsList from socket data',
      build: () => bloc,
      seed: () => const NewsState(newsList: [tNews]),
      act: (bloc) => bloc.add(OnNewsLikeUpdatedEvent(likeData: tLikeData)),
      expect: () => [
        isA<NewsState>()
            .having((s) => s.newsList[0].likesCount, 'likesCount', 10)
            .having((s) => s.newsList[0].isLiked, 'isLiked', true),
      ],
    );
  });
}
