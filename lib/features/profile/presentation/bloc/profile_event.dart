import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {

  const FetchProfileEvent({this.showLoader = true});
  final bool showLoader;

  @override
  List<Object> get props => [showLoader];
}

class UpdateProfileEvent extends ProfileEvent {

  const UpdateProfileEvent(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class UploadProfileImageEvent extends ProfileEvent {

  const UploadProfileImageEvent(this.imagePath);
  final String imagePath;

  @override
  List<Object> get props => [imagePath];
}

class ChangePasswordEvent extends ProfileEvent {

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });
  final String oldPassword;
  final String newPassword;

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class CheckUserNameEvent extends ProfileEvent {

  const CheckUserNameEvent(this.username);
  final String username;

  @override
  List<Object> get props => [username];
}

class CheckEmailEvent extends ProfileEvent {

  const CheckEmailEvent(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

class CheckPhoneEvent extends ProfileEvent {

  const CheckPhoneEvent(this.phone);
  final String phone;

  @override
  List<Object> get props => [phone];
}

class GetAvatarsEvent extends ProfileEvent {}
