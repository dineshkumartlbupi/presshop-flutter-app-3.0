import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_contact_info.dart';

abstract class AccountSettingsState extends Equatable {
  const AccountSettingsState();

  @override
  List<Object> get props => [];
}

class AccountSettingsInitial extends AccountSettingsState {}

class AccountSettingsLoading extends AccountSettingsState {}

class AdminContactInfoLoaded extends AccountSettingsState {
  const AdminContactInfoLoaded({required this.adminContactInfo});
  final AdminContactInfo adminContactInfo;

  @override
  List<Object> get props => [adminContactInfo];
}

class AccountDeleted extends AccountSettingsState {
  const AccountDeleted({this.message = 'Account deleted successfully'});
  final String message;

  @override
  List<Object> get props => [message];
}

class PasswordChangedSuccess extends AccountSettingsState {
  const PasswordChangedSuccess();
}

class AccountSettingsError extends AccountSettingsState {
  const AccountSettingsError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
