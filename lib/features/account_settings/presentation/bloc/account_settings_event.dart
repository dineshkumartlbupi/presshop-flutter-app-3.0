import 'package:equatable/equatable.dart';

abstract class AccountSettingsEvent extends Equatable {
  const AccountSettingsEvent();

  @override
  List<Object> get props => [];
}

class DeleteAccountEvent extends AccountSettingsEvent {

  const DeleteAccountEvent({required this.reason});
  final Map<String, String> reason;

  @override
  List<Object> get props => [reason];
}

class ChangePasswordEvent extends AccountSettingsEvent {

  const ChangePasswordEvent({required this.oldPassword, required this.newPassword});
  final String oldPassword;
  final String newPassword;


  @override
  List<Object> get props => [oldPassword, newPassword];
}

class GetAdminContactInfoEvent extends AccountSettingsEvent {
  const GetAdminContactInfoEvent();

  @override
  List<Object> get props => [];
}
