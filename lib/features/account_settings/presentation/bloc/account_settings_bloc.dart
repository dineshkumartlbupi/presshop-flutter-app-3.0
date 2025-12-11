import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/account_settings/presentation/bloc/account_settings_event.dart';
import 'package:presshop/features/account_settings/presentation/bloc/account_settings_state.dart';
import 'package:presshop/features/account_settings/presentation/pages/change_password_screen.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart' as cp;
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_admin_contact_info.dart';

class AccountSettingsBloc extends Bloc<AccountSettingsEvent, AccountSettingsState> {
  final DeleteAccount deleteAccount;
  final ChangePassword changePassword;
  final GetAdminContactInfo getAdminContactInfo;

  AccountSettingsBloc({
    required this.deleteAccount,
    required this.changePassword,
    required this.getAdminContactInfo,
  }) : super(AccountSettingsInitial()) {
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<ChangePasswordEvent>(_onChangePassword);
    on<GetAdminContactInfoEvent>(_onGetAdminContactInfo);
  }

  Future<void> _onGetAdminContactInfo(
    GetAdminContactInfoEvent event,
    Emitter<AccountSettingsState> emit,
  ) async {
    emit(AccountSettingsLoading());
    final result = await getAdminContactInfo(NoParams());
    result.fold(
      (failure) => emit(AccountSettingsError(message: failure.message)),
      (data) => emit(AdminContactInfoLoaded(adminContactInfo: data)),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AccountSettingsState> emit,
  ) async {
    emit(AccountSettingsLoading());
    final result = await deleteAccount(DeleteAccountParams(reason: event.reason));
    result.fold(
      (failure) => emit(AccountSettingsError(message: failure.message)),
      (success) => emit(const AccountDeleted()),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AccountSettingsState> emit,
  ) async {
    emit(AccountSettingsLoading());
    final result = await changePassword(cp.ChangePasswordParams(oldPassword: event.oldPassword, newPassword: event.newPassword));
    result.fold(
      (failure) => emit(AccountSettingsError(message: failure.message)),
      (success) => emit(const PasswordChangedSuccess()),
    );
  }

}
