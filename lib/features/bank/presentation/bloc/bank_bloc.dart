import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/usecases/delete_bank.dart';
import 'package:presshop/features/bank/domain/usecases/get_banks.dart';
import 'package:presshop/features/bank/domain/usecases/get_stripe_onboarding_url.dart';
import 'package:presshop/features/bank/domain/usecases/set_default_bank.dart';
import 'bank_event.dart';
import 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final GetBanks getBanks;
  final DeleteBank deleteBank;
  final SetDefaultBank setDefaultBank;
  final GetStripeOnboardingUrl getStripeOnboardingUrl;

  BankBloc({
    required this.getBanks,
    required this.deleteBank,
    required this.setDefaultBank,
    required this.getStripeOnboardingUrl,
  }) : super(BankInitial()) {
    on<FetchBanksEvent>(_onFetchBanks);
    on<DeleteBankEvent>(_onDeleteBank);
    on<SetDefaultBankEvent>(_onSetDefaultBank);
    on<GetStripeUrlEvent>(_onGetStripeUrl);
  }

  Future<void> _onFetchBanks(
    FetchBanksEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    final result = await getBanks(NoParams());
    result.fold(
      (failure) => emit(BankError(failure.message)),
      (banks) => emit(BanksLoaded(banks)),
    );
  }

  Future<void> _onDeleteBank(
    DeleteBankEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    final result = await deleteBank(DeleteBankParams(
      id: event.id,
      stripeBankId: event.stripeBankId,
    ));
    result.fold(
      (failure) => emit(BankError(failure.message)),
      (_) {
        emit(BankDeleted());
        add(FetchBanksEvent()); // Refresh list
      },
    );
  }

  Future<void> _onSetDefaultBank(
    SetDefaultBankEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    final result = await setDefaultBank(SetDefaultBankParams(
      stripeBankId: event.stripeBankId,
      isDefault: event.isDefault,
    ));
    result.fold(
      (failure) => emit(BankError(failure.message)),
      (_) {
        emit(BankDefaultSet());
        add(FetchBanksEvent()); // Refresh list
      },
    );
  }

  Future<void> _onGetStripeUrl(
    GetStripeUrlEvent event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    final result = await getStripeOnboardingUrl(NoParams());
    result.fold(
      (failure) => emit(BankError(failure.message)),
      (url) => emit(StripeUrlLoaded(url)),
    );
  }
}
