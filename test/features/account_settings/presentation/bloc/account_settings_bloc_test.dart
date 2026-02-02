import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/account_settings/domain/entities/admin_contact_info.dart';
import 'package:presshop/features/account_settings/domain/usecases/delete_account.dart';
import 'package:presshop/features/account_settings/domain/usecases/get_admin_contact_info.dart';
import 'package:presshop/features/profile/domain/usecases/change_password.dart'
    as cp;
import 'package:presshop/features/account_settings/presentation/bloc/account_settings_bloc.dart';
import 'package:presshop/features/account_settings/presentation/bloc/account_settings_event.dart';
import 'package:presshop/features/account_settings/presentation/bloc/account_settings_state.dart';

class MockDeleteAccount extends Mock implements DeleteAccount {}

class MockChangePassword extends Mock implements cp.ChangePassword {}

class MockGetAdminContactInfo extends Mock implements GetAdminContactInfo {}

void main() {
  late AccountSettingsBloc bloc;
  late MockDeleteAccount mockDeleteAccount;
  late MockChangePassword mockChangePassword;
  late MockGetAdminContactInfo mockGetAdminContactInfo;

  setUp(() {
    mockDeleteAccount = MockDeleteAccount();
    mockChangePassword = MockChangePassword();
    mockGetAdminContactInfo = MockGetAdminContactInfo();

    bloc = AccountSettingsBloc(
      deleteAccount: mockDeleteAccount,
      changePassword: mockChangePassword,
      getAdminContactInfo: mockGetAdminContactInfo,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(const DeleteAccountParams(reason: {}));
    registerFallbackValue(
        const cp.ChangePasswordParams(oldPassword: '', newPassword: ''));
  });

  const tAdminContactInfo = AdminContactInfo(email: 'admin@presshop.com');

  group('GetAdminContactInfoEvent', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'emits [AccountSettingsLoading, AdminContactInfoLoaded] when getting info passes',
      build: () {
        when(() => mockGetAdminContactInfo(any()))
            .thenAnswer((_) async => const Right(tAdminContactInfo));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAdminContactInfoEvent()),
      expect: () => [
        AccountSettingsLoading(),
        const AdminContactInfoLoaded(adminContactInfo: tAdminContactInfo),
      ],
    );
  });

  group('DeleteAccountEvent', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'emits [AccountSettingsLoading, AccountDeleted] when deletion passes',
      build: () {
        when(() => mockDeleteAccount(any()))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const DeleteAccountEvent(reason: {'reason': 'other'})),
      expect: () => [
        AccountSettingsLoading(),
        const AccountDeleted(),
      ],
    );
  });

  group('ChangePasswordEvent', () {
    blocTest<AccountSettingsBloc, AccountSettingsState>(
      'emits [AccountSettingsLoading, PasswordChangedSuccess] when change password passes',
      build: () {
        when(() => mockChangePassword(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
          const ChangePasswordEvent(oldPassword: 'old', newPassword: 'new')),
      expect: () => [
        AccountSettingsLoading(),
        const PasswordChangedSuccess(),
      ],
    );
  });
}
