import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Map<String, dynamic> data;

  const UpdateProfileEvent(this.data);

  @override
  List<Object> get props => [data];
}

class UploadProfileImageEvent extends ProfileEvent {
  final String imagePath;

  const UploadProfileImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class ChangePasswordEvent extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class CheckUserNameEvent extends ProfileEvent {
  final String username;

  const CheckUserNameEvent(this.username);

  @override
  List<Object> get props => [username];
}

class CheckEmailEvent extends ProfileEvent {
  final String email;

  const CheckEmailEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CheckPhoneEvent extends ProfileEvent {
  final String phone;

  const CheckPhoneEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class GetAvatarsEvent extends ProfileEvent {}
