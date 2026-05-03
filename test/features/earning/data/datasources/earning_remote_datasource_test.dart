import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/earning/data/datasources/earning_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late EarningRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = EarningRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('getEarningProfile', () {
    final tResponseData = {
      '_id': '1',
      'avatar_details': {'_id': 'a1', 'avatar': 'avatar'},
      'total_earning': '100'
    };

    test('should perform a GET request on earning profile URL', () async {
      // arrange
      when(() => mockApiClient.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final result = await dataSource.getEarningProfile('2023', '01');

      // assert
      expect(result.id, '1');
      expect(result.totalEarning,
          '100.0'); // It parses via double.tryParse(...).toString() which might add .0
    });
  });
}
