import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/content/data/datasources/content_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late ContentRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ContentRemoteDataSourceImpl(mockApiClient);
  });

  group('getMyContent', () {
    final tResponseData = {
      'code': 200,
      'data': {
        'code': 200,
        'contentList': [
          {
            '_id': '1',
            'description': 'Test Content',
            'location': 'London',
            'status': 'published',
            'id': '1',
          }
        ]
      }
    };

    test('should perform a GET request on myContentUrl', () async {
      // arrange
      when(() => mockApiClient.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final result = await dataSource.getMyContent(page: 1, limit: 10);

      // assert
      verify(() =>
          mockApiClient.get(any(), queryParameters: {'page': 1, 'limit': 10}));
      expect(result.length, 1);
      expect(result[0].id, '1');
    });

    test('should throw a ServerFailure when the call to API is unsuccessful',
        () async {
      // arrange
      when(() => mockApiClient.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'code': 404, 'message': 'Not Found'},
                statusCode: 404,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final call = dataSource.getMyContent;

      // assert
      expect(() => call(page: 1, limit: 10), throwsA(anything));
    });
  });
}
