import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/content/domain/entities/content_item.dart';
import 'package:presshop/features/content/domain/entities/category_data.dart';
import 'package:presshop/features/content/domain/usecases/get_my_content.dart';
import 'package:presshop/features/content/domain/usecases/publish_content.dart';
import 'package:presshop/features/content/domain/usecases/save_draft.dart';
import 'package:presshop/features/content/domain/usecases/upload_media.dart';
import 'package:presshop/features/content/domain/usecases/delete_content.dart';
import 'package:presshop/features/content/domain/usecases/search_hashtags.dart';
import 'package:presshop/features/content/domain/usecases/get_trending_hashtags.dart';
import 'package:presshop/features/content/domain/usecases/get_content_detail.dart';
import 'package:presshop/features/content/domain/usecases/get_media_house_offers.dart';
import 'package:presshop/features/content/domain/usecases/get_content_transactions.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_event.dart';
import 'package:presshop/features/content/presentation/bloc/content_state.dart';

class MockGetMyContent extends Mock implements GetMyContent {}

class MockPublishContent extends Mock implements PublishContent {}

class MockSaveDraft extends Mock implements SaveDraft {}

class MockUploadMedia extends Mock implements UploadMedia {}

class MockDeleteContent extends Mock implements DeleteContent {}

class MockSearchHashtags extends Mock implements SearchHashtags {}

class MockGetTrendingHashtags extends Mock implements GetTrendingHashtags {}

class MockGetContentDetail extends Mock implements GetContentDetail {}

class MockGetMediaHouseOffers extends Mock implements GetMediaHouseOffers {}

class MockGetContentTransactions extends Mock
    implements GetContentTransactions {}

void main() {
  late ContentBloc bloc;
  late MockGetMyContent mockGetMyContent;
  late MockPublishContent mockPublishContent;
  late MockSaveDraft mockSaveDraft;
  late MockUploadMedia mockUploadMedia;
  late MockDeleteContent mockDeleteContent;
  late MockSearchHashtags mockSearchHashtags;
  late MockGetTrendingHashtags mockGetTrendingHashtags;
  late MockGetContentDetail mockGetContentDetail;
  late MockGetMediaHouseOffers mockGetMediaHouseOffers;
  late MockGetContentTransactions mockGetContentTransactions;

  setUp(() {
    mockGetMyContent = MockGetMyContent();
    mockPublishContent = MockPublishContent();
    mockSaveDraft = MockSaveDraft();
    mockUploadMedia = MockUploadMedia();
    mockDeleteContent = MockDeleteContent();
    mockSearchHashtags = MockSearchHashtags();
    mockGetTrendingHashtags = MockGetTrendingHashtags();
    mockGetContentDetail = MockGetContentDetail();
    mockGetMediaHouseOffers = MockGetMediaHouseOffers();
    mockGetContentTransactions = MockGetContentTransactions();

    bloc = ContentBloc(
      getMyContent: mockGetMyContent,
      publishContent: mockPublishContent,
      saveDraft: mockSaveDraft,
      uploadMedia: mockUploadMedia,
      deleteContent: mockDeleteContent,
      searchHashtags: mockSearchHashtags,
      getTrendingHashtags: mockGetTrendingHashtags,
      getContentDetail: mockGetContentDetail,
      getMediaHouseOffers: mockGetMediaHouseOffers,
      getContentTransactions: mockGetContentTransactions,
    );

    registerFallbackValue(GetMyContentParams(page: 1, limit: 10));
    registerFallbackValue(PublishContentParams(data: const {}));
    registerFallbackValue(SaveDraftParams(data: const {}));
    registerFallbackValue(NoParams());
  });

  const tCategoryData = CategoryData(
    id: 'c1',
    name: 'Test Category',
    percentage: '10',
    type: 'type',
  );

  const tContentItem = ContentItem(
    id: '1',
    description: 'Description',
    location: 'London',
    latitude: '51.5',
    longitude: '-0.1',
    categoryId: 'c1',
    hopperId: 'h1',
    askPrice: '100',
    isDraft: false,
    isCharity: false,
    images: [],
    videos: [],
    createdAt: '2023-01-01',
    status: 'published',
    contentMetadata: [],
    productId: 'p1',
    priceOriginal: '100',
    currencyOriginal: 'GBP',
    imageCount: 0,
    videoCount: 0,
    contentUnderOffer: false,
    paidStatus: false,
    contentViewCount: 0,
    isFavourite: false,
    isLiked: false,
    categoryData: tCategoryData,
  );

  group('FetchMyContentEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, MyContentLoaded] when fetching content passes',
      build: () {
        when(() => mockGetMyContent(any()))
            .thenAnswer((_) async => const Right([tContentItem]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMyContentEvent(page: 1)),
      expect: () => [
        ContentLoading(),
        const MyContentLoaded(
            allContent: [tContentItem], allPage: 1, hasMoreAll: false),
      ],
    );

    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, ContentError] when fetching content fails',
      build: () {
        when(() => mockGetMyContent(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMyContentEvent(page: 1)),
      expect: () => [
        ContentLoading(),
        const ContentError('Error'),
      ],
    );
  });

  group('PublishContentEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, ContentPublished] when publishing content passes',
      build: () {
        when(() => mockPublishContent(any()))
            .thenAnswer((_) async => const Right(tContentItem));
        return bloc;
      },
      act: (bloc) => bloc.add(const PublishContentEvent({})),
      expect: () => [
        ContentLoading(),
        const ContentPublished(tContentItem),
      ],
    );
  });

  group('SaveDraftEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, DraftSaved] when saving draft passes',
      build: () {
        when(() => mockSaveDraft(any()))
            .thenAnswer((_) async => const Right(tContentItem));
        return bloc;
      },
      act: (bloc) => bloc.add(const SaveDraftEvent({})),
      expect: () => [
        ContentLoading(),
        const DraftSaved(tContentItem),
      ],
    );
  });

  group('UploadMediaEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, MediaUploaded] when upload passes',
      build: () {
        when(() => mockUploadMedia(any()))
            .thenAnswer((_) async => const Right(['url1']));
        return bloc;
      },
      act: (bloc) => bloc.add(const UploadMediaEvent(['path1'])),
      expect: () => [
        ContentLoading(),
        const MediaUploaded(['url1']),
      ],
    );
  });

  group('DeleteContentEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [ContentLoading, ContentDeleted] when deletion passes',
      build: () {
        when(() => mockDeleteContent(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteContentEvent('1')),
      expect: () => [
        ContentLoading(),
        const ContentDeleted('1'),
      ],
    );
  });

  group('SearchHashtagsEvent', () {
    blocTest<ContentBloc, ContentState>(
      'emits [HashtagsSearched] when search passes',
      build: () {
        when(() => mockSearchHashtags(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchHashtagsEvent('query')),
      expect: () => [
        const HashtagsSearched([]),
      ],
    );
  });
}
