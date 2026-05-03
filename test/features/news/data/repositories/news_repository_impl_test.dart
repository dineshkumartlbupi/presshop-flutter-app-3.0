import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/news/data/datasources/news_remote_datasource.dart';
import 'package:presshop/features/news/data/models/news_model.dart';
import 'package:presshop/features/news/data/repositories/news_repository_impl.dart';
import 'package:presshop/features/news/domain/entities/news.dart';

class MockNewsRemoteDataSource extends Mock implements NewsRemoteDataSource {}

void main() {
  late NewsRepositoryImpl repository;
  late MockNewsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockNewsRemoteDataSource();
    repository = NewsRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const tNewsModel =
      NewsModel(id: '1', title: 'Test News', description: 'Description');
  const News tNews = tNewsModel;

  group('getAggregatedNews', () {
    const tLat = 51.5;
    const tLng = -0.12;
    const tKm = 10.0;

    test('should return Right(List<News>) when successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'),
            category: any(named: 'category'),
            alertType: any(named: 'alertType'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [tNewsModel]);

      // act
      final result =
          await repository.getAggregatedNews(lat: tLat, lng: tLng, km: tKm);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should be Right'),
        (list) => expect(list, [tNews]),
      );
      verify(() => mockRemoteDataSource.getAggregatedNews(
            lat: tLat,
            lng: tLng,
            km: tKm,
            category: 'all',
            limit: 10,
            offset: 0,
          ));
    });

    test(
        'should return Left(ProcessingFailure) when ProcessingException occurs',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'),
            category: any(named: 'category'),
            alertType: any(named: 'alertType'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(ProcessingException('Processing'));

      // act
      final result =
          await repository.getAggregatedNews(lat: tLat, lng: tLng, km: tKm);

      // assert
      expect(result, const Left(ProcessingFailure(message: 'Processing')));
    });

    test('should return Left(ServerFailure) when ServerException occurs',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'),
            category: any(named: 'category'),
            alertType: any(named: 'alertType'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(ServerException('Error'));

      // act
      final result =
          await repository.getAggregatedNews(lat: tLat, lng: tLng, km: tKm);

      // assert
      expect(result, const Left(ServerFailure(message: 'Error')));
    });
  });

  group('getNewsDetail', () {
    test('should return Right(News) when successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getNewsDetail(any()))
          .thenAnswer((_) async => tNewsModel);

      // act
      final result = await repository.getNewsDetail('1');

      // assert
      expect(result, const Right(tNews));
    });
  });
}
