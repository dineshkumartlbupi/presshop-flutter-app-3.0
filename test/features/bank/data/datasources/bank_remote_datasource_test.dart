import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/bank/data/datasources/bank_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late BankRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = BankRemoteDataSourceImpl(mockApiClient);
  });

  group('getBanks', () {
    final tResponseData = {
      'code': 200,
      'bankList': [
        {
          'bank_detail': {
            '_id': '1',
            'acc_holder_name': 'John Doe',
            'stripe_bank_id': 's1'
          },
          'bank_name': 'Test Bank',
          'currency': 'GBP',
          'is_default': true,
          'acc_number': '12345678',
          'sort_code': '112233'
        }
      ]
    };

    test('should perform a GET request on bank list URL', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final result = await dataSource.getBanks();

      // assert
      expect(result.length, 1);
      expect(result[0].id, '1');
      expect(result[0].bankName, 'Test Bank');
    });

    test(
        'should throw a ServerFailure when the call to API returns non-200 code inside data',
        () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => Response(
            data: {'code': 400, 'message': 'Error'},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final call = dataSource.getBanks;

      // assert
      expect(() => call(), throwsA(anything));
    });
  });
}
