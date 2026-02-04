import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_data.dart';
import '../../domain/entities/avatar.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {

  const ProfileLoaded(this.profile);
  final ProfileData profile;

  @override
  List<Object> get props => [profile];
}

class ProfileUpdated extends ProfileState {

  const ProfileUpdated(this.profile);
  final ProfileData profile;

  @override
  List<Object> get props => [profile];
}

class ProfileImageUploaded extends ProfileState {

  const ProfileImageUploaded(this.imageUrl);
  final String imageUrl;

  @override
  List<Object> get props => [imageUrl];
}

class PasswordChanged extends ProfileState {}

class ProfileError extends ProfileState {

  const ProfileError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class UserNameChecked extends ProfileState {

  const UserNameChecked(this.isAvailable);
  final bool isAvailable;

  @override
  List<Object> get props => [isAvailable];
}

class EmailChecked extends ProfileState {

  const EmailChecked(this.isAvailable);
  final bool isAvailable;

  @override
  List<Object> get props => [isAvailable];
}

class PhoneChecked extends ProfileState {

  const PhoneChecked(this.isAvailable);
  final bool isAvailable;

  @override
  List<Object> get props => [isAvailable];
}

class AvatarsLoaded extends ProfileState {

  const AvatarsLoaded(this.avatars);
  final List<Avatar> avatars;

  @override
  List<Object> get props => [avatars];
}
