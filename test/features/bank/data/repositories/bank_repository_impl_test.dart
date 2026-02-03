import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/bank/data/repositories/bank_repository_impl.dart';
import 'package:presshop/features/bank/data/datasources/bank_remote_data_source.dart';
import 'package:presshop/features/bank/data/models/bank_detail_model.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';

class MockRemoteDataSource extends Mock implements BankRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late BankRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = BankRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tBankDetailModel = BankDetailModel(
    id: '1',
    bankName: 'Test Bank',
    bankImage: 'image',
    bankLocation: 'London',
    currency: 'GBP',
    isDefault: true,
    accountHolderName: 'John Doe',
    sortCode: '112233',
    accountNumber: '12345678',
    stripeBankId: 's1',
    availablePayoutMethods: [],
  );

  group('getBanks', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getBanks())
          .thenAnswer((_) async => [tBankDetailModel]);

      // act
      await repository.getBanks();

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
        when(() => mockRemoteDataSource.getBanks())
            .thenAnswer((_) async => [tBankDetailModel]);

        // act
        final result = await repository.getBanks();

        // assert
        verify(() => mockRemoteDataSource.getBanks());
        expect(result.isRight(), true);
        result.fold((l) => null, (r) => expect(r, [tBankDetailModel]));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        // arrange
        when(() => mockRemoteDataSource.getBanks()).thenThrow(Exception());

        // act
        final result = await repository.getBanks();

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
        final result = await repository.getBanks();

        // assert
        expect(result, const Left(NetworkFailure()));
      });
    });
  });
}
