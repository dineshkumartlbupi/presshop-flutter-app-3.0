import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:presshop/core/error/failures.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late DashboardRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = DashboardRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  group('getActiveAdmins', () {
    test('should return List<AdminDetailModel> when API call is successful',
        () async {
      // arrange
      final tResponse = {
        'success': true,
        'data': [
          {
            "_id": "A1",
            "name": "Admin1",
            "profile_image": "img1",
            "room_details": {
              "room_id": "R1",
              "sender_id": "S1",
              "receiver_id": "RE1",
              "room_type": "type1"
            }
          }
        ]
      };
      when(() => mockApiClient.get(any(), showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: tResponse,
                statusCode: 200,
              ));

      // act
      final result = await dataSource.getActiveAdmins();

      // assert
      verify(() =>
          mockApiClient.get(ApiConstantsNew.misc.adminList, showLoader: false));
      expect(result.first.id, "A1");
      expect(result.first.name, "Admin1");
    });

    test('should throw ServerFailure when statusCode is not 200', () async {
      // arrange
      when(() => mockApiClient.get(any(), showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {},
                statusCode: 404,
              ));

      // act
      final call = dataSource.getActiveAdmins();

      // assert
      expect(() => call, throwsA(isA<ServerFailure>()));
    });
  });

  group('checkAppVersion', () {
    test('should return version data when API call is successful', () async {
      // arrange
      final tResponse = {
        'success': true,
        'data': {'version': '1.0.0'}
      };
      when(() => mockApiClient.get(any(), showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: tResponse,
                statusCode: 200,
              ));

      // act
      final result = await dataSource.checkAppVersion();

      // assert
      expect(result['version'], '1.0.0');
    });
  });
}
