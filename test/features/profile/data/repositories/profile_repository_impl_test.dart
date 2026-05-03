import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:presshop/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:presshop/features/profile/data/models/user_profile_response.dart';
import 'package:presshop/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const tUserId = 'user123';
  final tUserProfileModel = UserProfileModel(
    id: tUserId,
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
    phone: '1234567890',
    userName: 'testuser',
    role: 'hopper',
    status: 'active',
    hopperStatus: 'approved',
    chatStatus: 'online',
    profileImage: '',
    isVerified: true,
    isOnboard: true,
    isDeleted: false,
    latitude: 0.0,
    longitude: 0.0,
    totalEarnings: 0,
    totalHopperArmy: 0,
    location: LocationModel(type: 'Point', coordinates: [0.0, 0.0]),
    preferredCurrencySign: PreferredCurrencySignModel(
      symbol: '\$',
      code: 'USD',
      name: 'Dollar',
      countryName: 'USA',
      countryCode: 'US',
      dialCode: '+1',
    ),
    createdAt: DateTime(2023),
    updatedAt: DateTime(2023),
    lastLogin: DateTime(2023),
    avatar: '',
  );

  group('getProfile', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getUserId())
          .thenAnswer((_) async => tUserId);
      when(() => mockRemoteDataSource.getProfile(any(),
              showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => tUserProfileModel);

      // act
      await repository.getProfile();

      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return ProfileData when remote data source is successful',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getUserId())
          .thenAnswer((_) async => tUserId);
      when(() => mockRemoteDataSource.getProfile(any(),
              showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => tUserProfileModel);

      // act
      final result = await repository.getProfile();

      // assert
      expect(result, Right(tUserProfileModel.toEntity()));
    });

    test('should return CacheFailure when userId is missing', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getUserId()).thenAnswer((_) async => null);

      // act
      final result = await repository.getProfile();

      // assert
      expect(result, const Left(CacheFailure(message: "User ID not found")));
    });

    test('should return NetworkFailure when device is offline', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getProfile();

      // assert
      expect(result, const Left(NetworkFailure()));
    });
  });

  group('updateProfile', () {
    test('should return ProfileData when update is successful', () async {
      // arrange
      final tData = {'first_name': 'New'};
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateProfile(any()))
          .thenAnswer((_) async => tUserProfileModel);

      // act
      final result = await repository.updateProfile(tData);

      // assert
      expect(result, Right(tUserProfileModel.toEntity()));
    });
  });
}
