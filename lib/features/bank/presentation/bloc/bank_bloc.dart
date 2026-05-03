import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/usecases/delete_bank.dart';
import 'package:presshop/features/bank/domain/usecases/get_banks.dart';
import 'package:presshop/features/bank/domain/usecases/get_stripe_onboarding_url.dart';
import 'package:presshop/features/bank/domain/usecases/set_default_bank.dart';
import 'package:presshop/features/bank/data/models/bank_detail_model.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';
import 'bank_event.dart';
import 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
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
  final GetBanks getBanks;
  final DeleteBank deleteBank;
  final SetDefaultBank setDefaultBank;
  final GetStripeOnboardingUrl getStripeOnboardingUrl;

  Future<void> _onFetchBanks(
    FetchBanksEvent event,
    Emitter<BankState> emit,
  ) async {
    final cacheBox = Hive.box('sync_cache');
    const String cacheKey = 'my_banks';

    debugPrint("BankBloc: Fetching banks starting...");

    final cachedData = cacheBox.get(cacheKey);
    if (cachedData != null && cachedData is List) {
      try {
        debugPrint("BankBloc: Found cached data: ${cachedData.length} items");
        final banks = cachedData
            .map((e) => BankDetailModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (banks.isNotEmpty) {
          emit(BanksLoaded(banks));
          debugPrint("BankBloc: Emitted cached banks");
        }
      } catch (e) {
        debugPrint("BankBloc: Error loading banks from cache: $e");
      }
    }

    if (state is! BanksLoaded) {
      debugPrint("BankBloc: Emitting BankLoading...");
      emit(BankLoading());
    }

    final result = await getBanks(NoParams());
    result.fold(
      (failure) {
        debugPrint("BankBloc: API Error: ${failure.message}");
        if (state is! BanksLoaded) {
          emit(BankError(failure.message));
        }
      },
      (banks) {
        debugPrint("BankBloc: API Success: ${banks.length} banks");
        try {
          cacheBox.put(cacheKey,
              banks.map((e) => (e as BankDetailModel).toJson()).toList());
          debugPrint("BankBloc: Cache updated in Hive");
        } catch (e) {
          debugPrint("BankBloc: Error updating cache: $e");
        }
        emit(BanksLoaded(banks));
        debugPrint("BankBloc: Emitted BanksLoaded from API");
      },
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
        add(FetchBanksEvent());
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
    // Preserve current bank data while loading Stripe URL
    final List<BankDetail> currentBanks =
        state is BanksLoaded ? (state as BanksLoaded).banks : [];
    emit(StripeUrlLoading(currentBanks));
    final result = await getStripeOnboardingUrl(NoParams());
    result.fold(
      (failure) => emit(currentBanks.isNotEmpty
          ? BanksLoaded(currentBanks)
          : BankError(failure.message)),
      (url) => emit(StripeUrlLoaded(url)),
    );
  }
}
