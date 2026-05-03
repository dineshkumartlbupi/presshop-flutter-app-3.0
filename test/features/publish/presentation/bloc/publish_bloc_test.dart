import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/publish/domain/entities/charity.dart';
import 'package:presshop/features/publish/domain/entities/content_category.dart';
import 'package:presshop/features/publish/domain/usecases/get_charities.dart';
import 'package:presshop/features/publish/domain/usecases/get_content_categories.dart';
import 'package:presshop/features/publish/domain/usecases/get_share_exclusive_price.dart';
import 'package:presshop/features/publish/domain/usecases/submit_content.dart';
import 'package:presshop/features/publish/presentation/bloc/publish_bloc.dart';
import 'package:presshop/features/publish/presentation/bloc/publish_event.dart';
import 'package:presshop/features/publish/presentation/bloc/publish_state.dart';

class MockGetContentCategories extends Mock implements GetContentCategories {}

class MockGetCharities extends Mock implements GetCharities {}

class MockGetShareExclusivePrice extends Mock
    implements GetShareExclusivePrice {}

class MockSubmitContent extends Mock implements SubmitContent {}

void main() {
  late PublishBloc bloc;
  late MockGetContentCategories mockGetContentCategories;
  late MockGetCharities mockGetCharities;
  late MockGetShareExclusivePrice mockGetShareExclusivePrice;
  late MockSubmitContent mockSubmitContent;

  setUp(() {
    mockGetContentCategories = MockGetContentCategories();
    mockGetCharities = MockGetCharities();
    mockGetShareExclusivePrice = MockGetShareExclusivePrice();
    mockSubmitContent = MockSubmitContent();

    bloc = PublishBloc(
      getContentCategories: mockGetContentCategories,
      getCharities: mockGetCharities,
      getShareExclusivePrice: mockGetShareExclusivePrice,
      submitContent: mockSubmitContent,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(const GetCharitiesParams(offset: 0, limit: 10));
    registerFallbackValue(const SubmitContentParams(params: {}, filePaths: []));
  });

  tearDown(() {
    bloc.close();
  });

  const tCategories = [
    ContentCategory(
        id: '1', name: 'News', type: 'news', percentage: '10', selected: true),
    ContentCategory(
        id: '2', name: 'Fun', type: 'fun', percentage: '20', selected: false),
  ];

  const tPrices = {'share': '10', 'exclusive': '100'};

  const tCharities = [
    Charity(
        id: '1',
        organisationNumber: '123',
        charityName: 'Red Cross',
        charityImage: 'img',
        country: 'US',
        isSelectCharity: false)
  ];

  group('PublishBloc', () {
    test('initial state is PublishStatus.initial', () {
      expect(bloc.state.status, PublishStatus.initial);
    });

    group('LoadPublishDataEvent', () {
      blocTest<PublishBloc, PublishState>(
        'emits [loading, loaded] with categories and prices when success',
        build: () {
          when(() => mockGetContentCategories(any()))
              .thenAnswer((_) async => const Right(tCategories));
          when(() => mockGetShareExclusivePrice(any()))
              .thenAnswer((_) async => const Right(tPrices));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadPublishDataEvent()),
        expect: () => [
          const PublishState(status: PublishStatus.loading),
          const PublishState(
            status: PublishStatus.loading,
            categories: tCategories,
            selectedCategory: ContentCategory(
                id: '1',
                name: 'News',
                type: 'news',
                percentage: '10',
                selected: true),
          ),
          const PublishState(
            status: PublishStatus.loading,
            categories: tCategories,
            prices: tPrices,
            selectedCategory: ContentCategory(
                id: '1',
                name: 'News',
                type: 'news',
                percentage: '10',
                selected: true),
          ),
          const PublishState(
            status: PublishStatus.loaded,
            categories: tCategories,
            prices: tPrices,
            selectedCategory: ContentCategory(
                id: '1',
                name: 'News',
                type: 'news',
                percentage: '10',
                selected: true),
          ),
        ],
      );

      blocTest<PublishBloc, PublishState>(
        'emits [loading, failure, loaded] when categories fail',
        build: () {
          when(() => mockGetContentCategories(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Cat Error')));
          when(() => mockGetShareExclusivePrice(any()))
              .thenAnswer((_) async => const Right(tPrices));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadPublishDataEvent()),
        expect: () => [
          const PublishState(status: PublishStatus.loading),
          const PublishState(
              status: PublishStatus.failure, errorMessage: 'Cat Error'),
          // The bloc continues to process prices and then emits loaded if status is not failure?
          // Code: if (state.status != PublishStatus.failure) { emit(state.copyWith(status: PublishStatus.loaded)); }
          // Since it IS failure, it won't emit loaded.
          const PublishState(
              status: PublishStatus.failure,
              errorMessage: 'Cat Error',
              prices: tPrices),
        ],
      );
    });

    group('FetchCharitiesEvent', () {
      blocTest<PublishBloc, PublishState>(
        'emits state with charities when success',
        build: () {
          when(() => mockGetCharities(any()))
              .thenAnswer((_) async => const Right(tCharities));
          return bloc;
        },
        act: (bloc) => bloc.add(const FetchCharitiesEvent()),
        expect: () => [
          const PublishState(charities: tCharities),
        ],
      );
    });

    group('SubmitContentEvent', () {
      blocTest<PublishBloc, PublishState>(
        'emits [submitting, success] when content submitted',
        build: () {
          when(() => mockSubmitContent(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(const SubmitContentEvent({}, [])),
        expect: () => [
          const PublishState(status: PublishStatus.submitting),
          const PublishState(status: PublishStatus.success),
        ],
      );
    });
  });
}
