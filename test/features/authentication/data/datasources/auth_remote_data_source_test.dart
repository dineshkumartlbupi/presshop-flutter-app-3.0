import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:presshop/features/authentication/data/models/user_model.dart';
import 'package:presshop/core/error/failures.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('login', () {
    const tUsername = 'test@example.com';
    const tPassword = 'password';
    final tLoginResponse = {
      'code': 200,
      'success': true,
      'data': {
        '_id': '1',
        'first_name': 'Test',
        'last_name': 'User',
        'email': 'test@example.com',
        'token': 'access_token',
        'refreshToken': 'refresh_token',
      }
    };

    test('should return UserModel when the response code is 200 (success)',
        () async {
      // arrange
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tLoginResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final result = await dataSource.login(tUsername, tPassword);

      // assert
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      expect(result.token, 'access_token');
    });

    test('should throw ServerFailure when response code is not 200', () async {
      // arrange
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {'message': 'Login failed'},
                statusCode: 401,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final call = dataSource.login;

      // assert
      expect(() => call(tUsername, tPassword), throwsA(isA<ServerFailure>()));
    });
  });

  group('forgotPassword', () {
    const tEmail = 'test@example.com';
    final tResponse = {
      'success': true,
      'data': {'code': 200, 'data': '123456'}
    };

    test('should return Right(otp) when successful', () async {
      // arrange
      when(() => mockApiClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // act
      final result = await dataSource.forgotPassword(tEmail);

      // assert
      result.fold(
        (l) => fail('Should be Right'),
        (r) => expect(r, '123456'),
      );
    });
  });
}
