import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/content/data/repositories/content_repository_impl.dart';
import 'package:presshop/features/content/data/datasources/content_remote_data_source.dart';
import 'package:presshop/features/content/data/models/all_content_model.dart';
import 'package:presshop/features/content/domain/entities/category_data.dart';

class MockRemoteDataSource extends Mock implements ContentRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ContentRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ContentRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tCategoryData = CategoryData(
    id: 'c1',
    name: 'Test Category',
    percentage: '10',
    type: 'type',
  );

  const tContentModel = ContentItemModel(
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

  group('getMyContent', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getMyContent(page: 1, limit: 10))
          .thenAnswer((_) async => [tContentModel]);

      // act
      await repository.getMyContent(page: 1, limit: 10);

      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getMyContent(page: 1, limit: 10))
            .thenAnswer((_) async => [tContentModel]);

        // act
        final result = await repository.getMyContent(page: 1, limit: 10);

        // assert
        verify(() => mockRemoteDataSource.getMyContent(page: 1, limit: 10));
        expect(result.isRight(), true);
        result.fold((l) => null, (r) => expect(r, [tContentModel]));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getMyContent(page: 1, limit: 10))
            .thenThrow(ServerFailure(message: 'Error'));

        // act
        final result = await repository.getMyContent(page: 1, limit: 10);

        // assert
        verify(() => mockRemoteDataSource.getMyContent(page: 1, limit: 10));
        expect(result, const Left(ServerFailure(message: 'Error')));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when the device is offline', () async {
        // act
        final result = await repository.getMyContent(page: 1, limit: 10);

        // assert
        expect(result, const Left(NetworkFailure()));
      });
    });
  });
}
