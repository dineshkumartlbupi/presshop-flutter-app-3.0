import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/account_settings/data/datasources/account_settings_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AccountSettingsRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AccountSettingsRemoteDataSourceImpl(mockApiClient);
  });

  group('getAdminContactInfo', () {
    final tResponseData = {
      'data': {'email': 'admin@presshop.com'}
    };

    test('should perform a GET request on admin detail URL', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final result = await dataSource.getAdminContactInfo();

      // assert
      expect(result.email, 'admin@presshop.com');
    });

    test('should throw a ServerFailure when the call to API is unsuccessful',
        () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => Response(
            data: 'Error',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final call = dataSource.getAdminContactInfo;

      // assert
      expect(() => call(), throwsA(anything));
    });
  });
}
