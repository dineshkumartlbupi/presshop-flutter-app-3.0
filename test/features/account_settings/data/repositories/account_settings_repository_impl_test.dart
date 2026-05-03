import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/account_settings/data/repositories/account_settings_repository_impl.dart';
import 'package:presshop/features/account_settings/data/datasources/account_settings_remote_datasource.dart';
import 'package:presshop/features/account_settings/data/models/admin_contact_info_model.dart';

class MockRemoteDataSource extends Mock
    implements AccountSettingsRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AccountSettingsRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AccountSettingsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tAdminContactInfoModel =
      AdminContactInfoModel(email: 'admin@presshop.com');

  group('getAdminContactInfo', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAdminContactInfo())
          .thenAnswer((_) async => tAdminContactInfoModel);

      // act
      await repository.getAdminContactInfo();

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
        when(() => mockRemoteDataSource.getAdminContactInfo())
            .thenAnswer((_) async => tAdminContactInfoModel);

        // act
        final result = await repository.getAdminContactInfo();

        // assert
        verify(() => mockRemoteDataSource.getAdminContactInfo());
        expect(result.isRight(), true);
        result.fold((l) => null, (r) => expect(r, tAdminContactInfoModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getAdminContactInfo())
            .thenThrow(Exception());

        // act
        final result = await repository.getAdminContactInfo();

        // assert
        expect(result.isLeft(), true);
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when the device is offline', () async {
        // act
        final result = await repository.getAdminContactInfo();

        // assert
        expect(result, const Left(NetworkFailure()));
      });
    });
  });
}
