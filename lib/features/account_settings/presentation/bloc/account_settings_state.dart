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
  final AdminContactInfo adminContactInfo;

  const AdminContactInfoLoaded({required this.adminContactInfo});

  @override
  List<Object> get props => [adminContactInfo];
}

class AccountDeleted extends AccountSettingsState {
  final String message;

  const AccountDeleted({this.message = 'Account deleted successfully'});

  @override
  List<Object> get props => [message];
}

class PasswordChangedSuccess extends AccountSettingsState {
  const PasswordChangedSuccess();
}

class AccountSettingsError extends AccountSettingsState {
  final String message;

  const AccountSettingsError({required this.message});

  @override
  List<Object> get props => [message];
}
