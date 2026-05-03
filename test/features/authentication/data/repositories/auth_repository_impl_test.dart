import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:presshop/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:presshop/features/authentication/data/models/user_model.dart';
import 'package:presshop/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUser = UserModel(
    id: '1',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
    token: 'access_token',
    refreshToken: 'refresh_token',
  );

  group('login', () {
    const tUsername = 'test@example.com';
    const tPassword = 'password';

    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tUser);
      when(() => mockLocalDataSource.cacheToken(any()))
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.cacheRefreshToken(any()))
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.setRememberMe(any()))
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.cacheUser(any()))
          .thenAnswer((_) async => true);

      // act
      await repository.login(tUsername, tPassword);

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
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => tUser);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheRefreshToken(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.setRememberMe(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => true);

        // act
        final result = await repository.login(tUsername, tPassword);

        // assert
        verify(() => mockRemoteDataSource.login(tUsername, tPassword));
        expect(result, equals(const Right(tUser)));
      });

      test('should cache the token and user details when login is successful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenAnswer((_) async => tUser);
        when(() => mockLocalDataSource.cacheToken(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheRefreshToken(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.setRememberMe(any()))
            .thenAnswer((_) async => true);
        when(() => mockLocalDataSource.cacheUser(any()))
            .thenAnswer((_) async => true);

        // act
        await repository.login(tUsername, tPassword);

        // assert
        verify(() => mockLocalDataSource.cacheToken(tUser.token!));
        verify(
            () => mockLocalDataSource.cacheRefreshToken(tUser.refreshToken!));
        verify(() => mockLocalDataSource.cacheUser(any()));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.login(any(), any()))
            .thenThrow(const ServerFailure(message: 'Login Failed'));

        // act
        final result = await repository.login(tUsername, tPassword);

        // assert
        verify(() => mockRemoteDataSource.login(tUsername, tPassword));
        expect(
            result, equals(const Left(ServerFailure(message: 'Login Failed'))));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return network failure when there is no internet connection',
          () async {
        // act
        final result = await repository.login(tUsername, tPassword);

        // assert
        expect(result, equals(const Left(NetworkFailure())));
      });
    });
  });
}
