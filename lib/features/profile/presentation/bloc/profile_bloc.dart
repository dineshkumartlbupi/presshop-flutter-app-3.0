import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/get_profile_data.dart';
import '../../domain/usecases/update_profile_data.dart';
import '../../domain/usecases/upload_profile_image.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/check_username.dart';
import '../../domain/usecases/get_avatars.dart';
import 'profile_event.dart';
import 'profile_state.dart';

import 'package:presshop/features/authentication/domain/usecases/check_email.dart';
import 'package:presshop/features/authentication/domain/usecases/check_phone.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileData getProfileData;
  final UpdateProfileData updateProfileData;
  final UploadProfileImage uploadProfileImage;
  final ChangePassword changePassword;
  final CheckUserName checkUserName;
  final GetAvatars getAvatars;
  final CheckEmail checkEmail;
  final CheckPhone checkPhone;

  ProfileBloc({
    required this.getProfileData,
    required this.updateProfileData,
    required this.uploadProfileImage,
    required this.changePassword,
    required this.checkUserName,
    required this.getAvatars,
    required this.checkEmail,
    required this.checkPhone,
  }) : super(ProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<ChangePasswordEvent>(_onChangePassword);
    on<CheckUserNameEvent>(_onCheckUserName);
    on<GetAvatarsEvent>(_onGetAvatars);
    on<CheckEmailEvent>(_onCheckEmail);
    on<CheckPhoneEvent>(_onCheckPhone);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getProfileData(NoParams());
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await updateProfileData(UpdateProfileParams(data: event.data));
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await uploadProfileImage(event.imagePath);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (imageUrl) => emit(ProfileImageUploaded(imageUrl)),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await changePassword(
      ChangePasswordParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(PasswordChanged()),
    );
  }

  Future<void> _onCheckUserName(
    CheckUserNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await checkUserName(CheckUserNameParams(username: event.username));
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (isAvailable) => emit(UserNameChecked(isAvailable)),
    );
  }

  Future<void> _onCheckEmail(
    CheckEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await checkEmail(event.email);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (isAvailable) => emit(EmailChecked(isAvailable)),
    );
  }

  Future<void> _onCheckPhone(
    CheckPhoneEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await checkPhone(event.phone);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (isAvailable) => emit(PhoneChecked(isAvailable)),
    );
  }

  Future<void> _onGetAvatars(
    GetAvatarsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await getAvatars(NoParams());
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (avatars) => emit(AvatarsLoaded(avatars)),
    );
  }
}
