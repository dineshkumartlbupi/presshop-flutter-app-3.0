import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/notification/data/datasources/notification_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late NotificationRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = NotificationRemoteDataSourceImpl(apiClient: mockApiClient);
  });

  const tLimit = 10;
  const tOffset = 0;

  group('getNotifications', () {
    test('should perform a GET request on notificationList URL', () async {
      // arrange
      final tResponseData = {
        'data': {'data': []}
      };
      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            showLoader: any(named: 'showLoader'),
          )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      final result = await dataSource.getNotifications(tLimit, tOffset);

      // assert
      verify(() => mockApiClient.get(
            any(),
            queryParameters: {'limit': tLimit, 'offset': tOffset},
            showLoader: false,
          ));
      expect(result, tResponseData);
    });

    test('should throw an Exception when the call to API is unsuccessful',
        () async {
      // arrange
      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            showLoader: any(named: 'showLoader'),
          )).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // act
      final call = dataSource.getNotifications(tLimit, tOffset);

      // assert
      expect(() => call, throwsA(anything));
    });
  });

  group('markNotificationsAsRead', () {
    test('should perform a PATCH request', () async {
      // arrange
      when(() => mockApiClient.patch(any())).thenAnswer((_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      await dataSource.markNotificationsAsRead();

      // assert
      verify(() => mockApiClient.patch(any()));
    });
  });

  group('clearAllNotifications', () {
    test('should perform a PATCH request', () async {
      // arrange
      when(() => mockApiClient.patch(any())).thenAnswer((_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // act
      await dataSource.clearAllNotifications();

      // assert
      verify(() => mockApiClient.patch(any()));
    });
  });
}
