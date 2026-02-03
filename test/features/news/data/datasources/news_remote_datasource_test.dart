import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/news/data/datasources/news_remote_datasource.dart';
import 'package:presshop/features/news/data/models/news_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late NewsRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = NewsRemoteDataSourceImpl(client: mockApiClient);
  });

  final tNewsJson = <String, dynamic>{
    '_id': '1',
    'title': 'Test News',
    'description': 'Description',
  };

  group('getAggregatedNews', () {
    test('should return List<NewsModel> when response code is 200', () async {
      // arrange
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'data': {
            'news': [tNewsJson]
          }
        },
        statusCode: 200,
      );
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      // act
      final result = await dataSource.getAggregatedNews(lat: 0, lng: 0, km: 10);

      // assert
      expect(result.length, 1);
      expect(result[0].id, '1');
    });

    test('should throw ProcessingFailure when response code is 202', () async {
      // arrange
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 202,
      );
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      // act & assert
      expect(() => dataSource.getAggregatedNews(lat: 0, lng: 0, km: 10),
          throwsA(isA<Failure>()));
    });
  });

  group('getNewsDetail', () {
    test('should return NewsModel with enriched stats', () async {
      // arrange
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: {
          'data': tNewsJson,
          'stats': {
            'likes': 10,
            'comments': 5,
            'shares': 2,
            'views': 100,
            'is_liked': true,
          }
        },
        statusCode: 200,
      );
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      // act
      final result = await dataSource.getNewsDetail('1');

      // assert
      expect(result.likesCount, 10);
      expect(result.isLiked, true);
      expect(result.viewCount, 100);
    });
  });
}
