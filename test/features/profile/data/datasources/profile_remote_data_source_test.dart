import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:presshop/features/profile/data/models/user_profile_response.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApiClient = MockApiClient();
    mockPrefs = MockSharedPreferences();
    dataSource = ProfileRemoteDataSourceImpl(mockApiClient);

    when(() => mockApiClient.sharedPreferences).thenReturn(mockPrefs);
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
    test('should perform a GET request and return UserProfileModel on success',
        () async {
      // arrange
      final tResponse = {
        'success': true,
        'code': 200,
        'data': tUserProfileModel.toJson(),
      };

      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
            showLoader: any(named: 'showLoader'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: tResponse,
            statusCode: 200,
          ));

      // act
      final result = await dataSource.getProfile(tUserId);

      // assert
      verify(() => mockApiClient.get(
            ApiConstantsNew.profile.myProfile,
            queryParameters: {"userId": tUserId},
            showLoader: true,
          )).called(1);
      expect(result.id, tUserId);
    });

    test('should throw ServerFailure when API response success is false',
        () async {
      // arrange
      when(() => mockApiClient.get(any(),
              queryParameters: any(named: 'queryParameters'),
              showLoader: any(named: 'showLoader')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {'success': false, 'message': 'Not Found'},
                statusCode: 200,
              ));

      // act
      final call = dataSource.getProfile(tUserId);

      // assert
      expect(() => call, throwsA(isA<ServerFailure>()));
    });
  });

  group('updateProfile', () {
    test(
        'should perform a POST request and return UserProfileModel on success (no image)',
        () async {
      // arrange
      final tData = {'first_name': 'New'};
      final tResponse = {
        'success': true,
        'code': 200,
        'data': tUserProfileModel.toJson(),
      };

      when(() => mockPrefs.getString(hopperIdKey)).thenReturn(tUserId);
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: tResponse,
            statusCode: 200,
          ));

      // act
      final result = await dataSource.updateProfile(tData);

      // assert
      verify(() => mockApiClient.post(
            ApiConstantsNew.profile.editProfile,
            data: tData,
            options: any(named: 'options'),
          )).called(1);
      expect(result.id, tUserId);
    });
  });
}
