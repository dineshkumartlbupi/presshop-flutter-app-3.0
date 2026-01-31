import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/authentication/domain/usecases/check_email.dart';
import 'package:presshop/features/authentication/domain/usecases/check_phone.dart';
import 'package:presshop/features/profile/domain/entities/profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart';
import 'package:presshop/features/profile/domain/usecases/check_username.dart';
import 'package:presshop/features/profile/domain/usecases/get_avatars.dart';
import 'package:presshop/features/profile/domain/usecases/get_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/update_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/upload_profile_image.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_event.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_state.dart';

class MockGetProfileData extends Mock implements GetProfileData {}

class MockUpdateProfileData extends Mock implements UpdateProfileData {}

class MockUploadProfileImage extends Mock implements UploadProfileImage {}

class MockChangePassword extends Mock implements ChangePassword {}

class MockCheckUserName extends Mock implements CheckUserName {}

class MockGetAvatars extends Mock implements GetAvatars {}

class MockCheckEmail extends Mock implements CheckEmail {}

class MockCheckPhone extends Mock implements CheckPhone {}

void main() {
  late ProfileBloc bloc;
  late MockGetProfileData mockGetProfileData;
  late MockUpdateProfileData mockUpdateProfileData;
  late MockUploadProfileImage mockUploadProfileImage;
  late MockChangePassword mockChangePassword;
  late MockCheckUserName mockCheckUserName;
  late MockGetAvatars mockGetAvatars;
  late MockCheckEmail mockCheckEmail;
  late MockCheckPhone mockCheckPhone;

  setUp(() {
    mockGetProfileData = MockGetProfileData();
    mockUpdateProfileData = MockUpdateProfileData();
    mockUploadProfileImage = MockUploadProfileImage();
    mockChangePassword = MockChangePassword();
    mockCheckUserName = MockCheckUserName();
    mockGetAvatars = MockGetAvatars();
    mockCheckEmail = MockCheckEmail();
    mockCheckPhone = MockCheckPhone();

    bloc = ProfileBloc(
      getProfileData: mockGetProfileData,
      updateProfileData: mockUpdateProfileData,
      uploadProfileImage: mockUploadProfileImage,
      changePassword: mockChangePassword,
      checkUserName: mockCheckUserName,
      getAvatars: mockGetAvatars,
      checkEmail: mockCheckEmail,
      checkPhone: mockCheckPhone,
    );
  });

  final tProfileData = ProfileData(
    id: "1",
    firstName: "Test",
    lastName: "User",
    email: "test@example.com",
    phone: "1234567890",
    userName: "testuser",
    role: "hopper",
    status: "active",
    hopperStatus: "approved",
    chatStatus: "online",
    profileImage: "",
    isVerified: true,
    isOnboard: true,
    isDeleted: false,
    latitude: 0.0,
    longitude: 0.0,
    totalEarnings: 0,
    totalHopperArmy: 0,
    location: const Location(type: "Point", coordinates: [0.0, 0.0]),
    preferredCurrencySign: const PreferredCurrencySign(
        symbol: "\$",
        code: "USD",
        name: "Dollar",
        countryName: "USA",
        countryCode: "US",
        dialCode: "+1"),
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
    lastLogin: DateTime(2023, 1, 1),
  );

  // Since ProfileData requires DateTime now (based on my previous read), let's use a dummy date for strict non-null fields
  final tDate = DateTime(2023, 1, 1);
  final tStrictProfileData = ProfileData(
    id: "1",
    firstName: "Test",
    lastName: "User",
    email: "test@example.com",
    phone: "1234567890",
    userName: "testuser",
    role: "hopper",
    status: "active",
    hopperStatus: "approved",
    chatStatus: "online",
    profileImage: "",
    isVerified: true,
    isOnboard: true,
    isDeleted: false,
    latitude: 0.0,
    longitude: 0.0,
    totalEarnings: 0,
    totalHopperArmy: 0,
    location: const Location(type: "Point", coordinates: [0.0, 0.0]),
    preferredCurrencySign: const PreferredCurrencySign(
        symbol: "\$",
        code: "USD",
        name: "Dollar",
        countryName: "USA",
        countryCode: "US",
        dialCode: "+1"),
    createdAt: tDate,
    updatedAt: tDate,
    lastLogin: tDate,
  );

  group('ProfileBloc', () {
    test('initial state should be ProfileInitial', () {
      expect(bloc.state, equals(ProfileInitial()));
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when fetching profile passes',
      build: () {
        when(() => mockGetProfileData(NoParams()))
            .thenAnswer((_) async => Right(tStrictProfileData));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchProfileEvent()),
      expect: () => [
        ProfileLoading(),
        ProfileLoaded(tStrictProfileData),
      ],
      verify: (_) {
        verify(() => mockGetProfileData(NoParams())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when fetching profile fails',
      build: () {
        when(() => mockGetProfileData(NoParams())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Server Failure')));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchProfileEvent()),
      expect: () => [
        ProfileLoading(),
        const ProfileError('Server Failure'),
      ],
      verify: (_) {
        verify(() => mockGetProfileData(NoParams())).called(1);
      },
    );
  });
}
