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
  final ProfileData profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final ProfileData profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileImageUploaded extends ProfileState {
  final String imageUrl;

  const ProfileImageUploaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class PasswordChanged extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class UserNameChecked extends ProfileState {
  final bool isAvailable;

  const UserNameChecked(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class EmailChecked extends ProfileState {
  final bool isAvailable;

  const EmailChecked(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class PhoneChecked extends ProfileState {
  final bool isAvailable;

  const PhoneChecked(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class AvatarsLoaded extends ProfileState {
  final List<Avatar> avatars;

  const AvatarsLoaded(this.avatars);

  @override
  List<Object> get props => [avatars];
}
