import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/authentication/domain/usecases/check_email.dart';
import 'package:presshop/features/authentication/domain/usecases/check_phone.dart';
import 'package:presshop/features/profile/domain/entities/profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart';
import 'package:presshop/features/profile/domain/usecases/check_username.dart';
import 'package:presshop/features/profile/domain/usecases/get_avatars.dart';
import 'package:presshop/features/profile/domain/usecases/get_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/update_profile_data.dart';
import 'package:presshop/features/profile/domain/usecases/upload_profile_image.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/profile/domain/entities/avatar.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_event.dart';
import 'package:presshop/features/profile/presentation/bloc/profile_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MockGetProfileData extends Mock implements GetProfileData {}

class MockUpdateProfileData extends Mock implements UpdateProfileData {}

class MockUploadProfileImage extends Mock implements UploadProfileImage {}

class MockChangePassword extends Mock implements ChangePassword {}

class MockCheckUserName extends Mock implements CheckUserName {}

class MockGetAvatars extends Mock implements GetAvatars {}

class MockCheckEmail extends Mock implements CheckEmail {}

class MockCheckPhone extends Mock implements CheckPhone {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

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
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() async {
    mockGetProfileData = MockGetProfileData();
    mockUpdateProfileData = MockUpdateProfileData();
    mockUploadProfileImage = MockUploadProfileImage();
    mockChangePassword = MockChangePassword();
    mockCheckUserName = MockCheckUserName();
    mockGetAvatars = MockGetAvatars();
    mockCheckEmail = MockCheckEmail();
    mockCheckPhone = MockCheckPhone();
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    // Reset sl and register mocks for AppLogger
    await sl.reset();
    sl.registerLazySingleton<FirebaseAnalytics>(() => mockAnalytics);
    sl.registerLazySingleton<FirebaseCrashlytics>(() => mockCrashlytics);

    // Default mocks for Firebase
    when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'))).thenAnswer((_) async => {});
    when(() => mockAnalytics.setUserId(id: any(named: 'id')))
        .thenAnswer((_) async => {});
    when(() => mockAnalytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'))).thenAnswer((_) async => {});
    when(() => mockCrashlytics.recordError(any(), any(),
        reason: any(named: 'reason'),
        information: any(named: 'information'),
        printDetails: any(named: 'printDetails'),
        fatal: any(named: 'fatal'))).thenAnswer((_) async => {});
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async => {});
    when(() => mockCrashlytics.setUserIdentifier(any()))
        .thenAnswer((_) async => {});
    when(() => mockCrashlytics.setCustomKey(any(), any()))
        .thenAnswer((_) async => {});

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
    avatar: '',
  );

  group('ProfileBloc', () {
    test('initial state should be ProfileInitial', () {
      expect(bloc.state, equals(ProfileInitial()));
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when fetching profile passes',
      build: () {
        when(() => mockGetProfileData(const GetProfileParams()))
            .thenAnswer((_) async => Right(tStrictProfileData));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchProfileEvent()),
      expect: () => [
        ProfileLoading(),
        ProfileLoaded(tStrictProfileData),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileUpdated] and tracks event when updating profile passes',
      build: () {
        when(() => mockUpdateProfileData(any()))
            .thenAnswer((_) async => Right(tStrictProfileData));
        when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'))).thenAnswer((_) async => {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateProfileEvent({})),
      expect: () => [
        ProfileLoading(),
        ProfileUpdated(tStrictProfileData),
      ],
      verify: (_) {
        verify(() => mockAnalytics.logEvent(
              name: EventNames.profileUpdated,
              parameters: any(named: 'parameters'),
            )).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] and logs error when updating profile fails',
      build: () {
        when(() => mockUpdateProfileData(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Update Failed')));
        when(() => mockCrashlytics.recordError(any(), any(),
            reason: any(named: 'reason'))).thenAnswer((_) async => {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateProfileEvent({})),
      expect: () => [
        ProfileLoading(),
        const ProfileError('Update Failed'),
      ],
      verify: (_) {
        verify(() => mockCrashlytics.recordError(
              any(),
              any(),
              reason: contains('Failed to update profile'),
            )).called(1);
      },
    );
  }); // Closing the first group here

  setUpAll(() {
    registerFallbackValue(
        ChangePasswordParams(oldPassword: '', newPassword: ''));
    registerFallbackValue(const CheckUserNameParams(username: ''));
    registerFallbackValue(NoParams());
    registerFallbackValue(UpdateProfileParams(data: {}));
    registerFallbackValue(const GetProfileParams());
  });

  group('ProfileBloc Additional Tests', () {
    const tAvatars = [Avatar(id: '1', avatar: 'img1')];

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileImageUploaded] when uploading image passes',
      build: () {
        when(() => mockUploadProfileImage(any()))
            .thenAnswer((_) async => const Right('http://image.jpg'));
        return bloc;
      },
      act: (bloc) => bloc.add(const UploadProfileImageEvent('path/to/image')),
      expect: () => [
        ProfileLoading(),
        ProfileImageUploaded('http://image.jpg'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, PasswordChanged] when changing password passes',
      build: () {
        when(() => mockChangePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const ChangePasswordEvent(
        oldPassword: 'old',
        newPassword: 'new',
      )),
      expect: () => [
        ProfileLoading(),
        PasswordChanged(),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [UserNameChecked] when checking username passes',
      build: () {
        when(() => mockCheckUserName(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckUserNameEvent('newuser')),
      expect: () => [
        UserNameChecked(true),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, AvatarsLoaded] when fetching avatars passes',
      build: () {
        when(() => mockGetAvatars(any()))
            .thenAnswer((_) async => const Right(tAvatars));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAvatarsEvent()),
      expect: () => [
        ProfileLoading(),
        AvatarsLoaded(tAvatars),
      ],
    );
  });
}
