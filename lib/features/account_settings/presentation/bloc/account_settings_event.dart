import 'package:equatable/equatable.dart';

abstract class AccountSettingsEvent extends Equatable {
  const AccountSettingsEvent();

  @override
  List<Object> get props => [];
}

class DeleteAccountEvent extends AccountSettingsEvent {
  final Map<String, String> reason;

  const DeleteAccountEvent({required this.reason});

  @override
  List<Object> get props => [reason];
}

class ChangePasswordEvent extends AccountSettingsEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({required this.oldPassword, required this.newPassword});


  @override
  List<Object> get props => [oldPassword, newPassword];
}

class GetAdminContactInfoEvent extends AccountSettingsEvent {
  const GetAdminContactInfoEvent();

  @override
  List<Object> get props => [];
}
