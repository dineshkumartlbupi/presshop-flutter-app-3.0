import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/earning/data/repositories/earning_repository_impl.dart';
import 'package:presshop/features/earning/data/datasources/earning_remote_data_source.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/domain/entities/earning_profile.dart';

class MockRemoteDataSource extends Mock implements EarningRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late EarningRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = EarningRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tEarningProfileModel = EarningProfileDataModel(
    id: '1',
    avatarId: 'a1',
    avatar: 'avatar',
    totalEarning: '100',
    currency: '',
    currencySymbol: '',
  );

  const tEarningProfile = EarningProfile(
    id: '1',
    avatar: 'avatar',
    totalEarning: '100',
  );

  group('getEarningProfile', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getEarningProfile(any(), any()))
          .thenAnswer((_) async => tEarningProfileModel);

      // act
      await repository.getEarningProfile('2023', '01');

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
        when(() => mockRemoteDataSource.getEarningProfile(any(), any()))
            .thenAnswer((_) async => tEarningProfileModel);

        // act
        final result = await repository.getEarningProfile('2023', '01');

        // assert
        verify(() => mockRemoteDataSource.getEarningProfile('2023', '01'));
        expect(result, const Right(tEarningProfile));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getEarningProfile(any(), any()))
            .thenThrow(Exception());

        // act
        final result = await repository.getEarningProfile('2023', '01');

        // assert
        expect(result, isA<Left<Failure, EarningProfile>>());
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when the device is offline', () async {
        // act
        final result = await repository.getEarningProfile('2023', '01');

        // assert
        expect(result, const Left(NetworkFailure()));
      });
    });
  });
}
