import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/usecases/get_earning_profile.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_commissions.dart';
import '../../domain/entities/earning_transaction.dart';
import '../../domain/entities/earning_profile.dart';
import '../../domain/entities/commission.dart';
import 'earning_event.dart';
import 'earning_state.dart';

class EarningBloc extends Bloc<EarningEvent, EarningState> {
  EarningBloc({
    required this.getEarningProfile,
    required this.getTransactions,
    required this.getCommissions,
  }) : super(const EarningState()) {
    on<FetchEarningDataEvent>(_onFetchEarningData);
    on<FetchTransactionsEvent>(_onFetchTransactions);
    on<FetchCommissionsEvent>(_onFetchCommissions);
    on<ChangeTabEvent>(_onChangeTab);
    on<UpdateDateEvent>(_onUpdateDate);
  }
  final GetEarningProfile getEarningProfile;
  final GetTransactions getTransactions;
  final GetCommissions getCommissions;

  Future<void> _onFetchEarningData(
      FetchEarningDataEvent event, Emitter<EarningState> emit) async {
    final cacheBox = Hive.box('sync_cache');
    final String cacheKey = 'earning_profile_${event.fromDate}_${event.toDate}';
    final cachedData = cacheBox.get(cacheKey);

    if (cachedData != null && cachedData is Map) {
      try {
        final profile = EarningProfile(
          id: (cachedData['id'] ?? '').toString(),
          avatar: (cachedData['avatar'] ?? '').toString(),
          totalEarning: (cachedData['total_earning'] ?? '').toString(),
          currency: (cachedData['currency'] ?? '').toString(),
          currencySymbol: (cachedData['currency_symbol'] ?? '').toString(),
        );
        emit(state.copyWith(
            status: EarningStatus.success, earningData: profile));
      } catch (e) {
        debugPrint("Error loading earning profile from cache: $e");
      }
    }

    if (state.status != EarningStatus.success) {
      emit(state.copyWith(status: EarningStatus.loading));
    }

    final result = await getEarningProfile(
        GetEarningProfileParams(year: event.fromDate, month: event.toDate));

    result.fold(
      (failure) {
        if (state.earningData == null) {
          emit(state.copyWith(
              status: EarningStatus.failure, errorMessage: failure.toString()));
        }
      },
      (profile) {
        cacheBox.put(cacheKey, profile.toJson());
        emit(state.copyWith(
          status: EarningStatus.success,
          earningData: profile,
        ));
      },
    );
  }

  Future<void> _onFetchTransactions(
      FetchTransactionsEvent event, Emitter<EarningState> emit) async {
    final cacheBox = Hive.box('sync_cache');
    // Using simple key for initial page caching
    final String cacheKey = 'earning_transactions';

    if (event.offset == 0) {
      final cachedData = cacheBox.get(cacheKey);
      if (cachedData != null && cachedData is Map) {
        try {
          final List list = cachedData['transactions'] ?? [];
          final transactions = list
              .map((e) => EarningTransaction(
                    id: (e['id'] ?? '').toString(),
                    amount: (e['amount'] ?? '').toString(),
                    totalEarningAmt: (e['totalEarningAmt'] ?? '').toString(),
                    status: (e['status'] ?? '').toString(),
                    paidStatus: e['paidStatus'] ?? false,
                    contentTitle: (e['contentTitle'] ?? '').toString(),
                    contentType: (e['contentType'] ?? '').toString(),
                    createdAt: (e['createdAt'] ?? '').toString(),
                    dueDate: (e['dueDate'] ?? '').toString(),
                    adminFullName: (e['adminFullName'] ?? '').toString(),
                    companyLogo: (e['companyLogo'] ?? '').toString(),
                    contentImage: (e['contentImage'] ?? '').toString(),
                    payableT0Hopper: (e['payableT0Hopper'] ?? '').toString(),
                    payableCommission:
                        (e['payableCommission'] ?? '').toString(),
                    stripefee: (e['stripefee'] ?? '').toString(),
                    hopperBankLogo: (e['hopperBankLogo'] ?? '').toString(),
                    hopperBankName: (e['hopperBankName'] ?? '').toString(),
                    userFirstName: (e['userFirstName'] ?? '').toString(),
                    userLastName: (e['userLastName'] ?? '').toString(),
                    contentDataList: e['contentDataList'] ?? [],
                    type: (e['type'] ?? '').toString(),
                    typesOfContent: e['typesOfContent'] ?? false,
                    hopperAvatar: (e['hopperAvatar'] ?? '').toString(),
                    uploadContent: (e['uploadContent'] ?? '').toString(),
                    contentId: (e['contentId'] ?? '').toString(),
                    currency: (e['currency'] ?? '').toString(),
                    currencySymbol: (e['currencySymbol'] ?? '').toString(),
                  ))
              .toList();

          if (transactions.isNotEmpty) {
            emit(state.copyWith(
              transactionStatus: EarningStatus.success,
              transactions: transactions,
              monthlyEarnings: cachedData['monthlyEarnings']?.toString() ?? '',
            ));
          }
        } catch (e) {
          debugPrint("Error loading earning transactions from cache: $e");
        }
      }

      if (state.transactions.isEmpty) {
        emit(state.copyWith(transactionStatus: EarningStatus.loading));
      }
    }

    final result = await getTransactions(
        GetTransactionsParams(params: event.filterParams));

    result.fold(
      (failure) {
        if (state.transactions.isEmpty) {
          emit(state.copyWith(
              transactionStatus: EarningStatus.failure,
              errorMessage: failure.toString()));
        }
      },
      (resultData) {
        final transactions = resultData.transactions;
        final monthlyEarnings = resultData.totalEarning;

        if (event.offset == 0) {
          cacheBox.put(cacheKey, {
            'transactions': transactions.map((e) => e.toJson()).toList(),
            'monthlyEarnings': monthlyEarnings,
          });
        }

        bool hasReachedMax = transactions.length < event.limit;

        emit(state.copyWith(
          transactionStatus: EarningStatus.success,
          transactions: event.offset == 0
              ? transactions
              : [...state.transactions, ...transactions],
          hasReachedMaxTransactions: hasReachedMax,
          monthlyEarnings: monthlyEarnings,
        ));
      },
    );
  }

  Future<void> _onFetchCommissions(
      FetchCommissionsEvent event, Emitter<EarningState> emit) async {
    final cacheBox = Hive.box('sync_cache');
    final String cacheKey = 'earning_commissions';

    if (event.offset == 0) {
      final cachedData = cacheBox.get(cacheKey);
      if (cachedData != null && cachedData is List) {
        try {
          final commissions = cachedData
              .map((e) => Commission(
                    totalEarning: (e['totalEarning'] ?? 0.0).toDouble(),
                    commission: (e['commission'] ?? 0.0).toDouble(),
                    commissionReceived:
                        (e['commissionReceived'] ?? 0.0).toDouble(),
                    commissionPending:
                        (e['commissionPending'] ?? 0.0).toDouble(),
                    paidOn: e['paidOn'],
                    firstName: (e['firstName'] ?? '').toString(),
                    lastName: (e['lastName'] ?? '').toString(),
                    dateOfJoining: (e['dateOfJoining'] ?? '').toString(),
                    avatar: (e['avatar'] ?? '').toString(),
                    currency: (e['currency'] ?? '').toString(),
                    currencySymbol: (e['currencySymbol'] ?? '').toString(),
                  ))
              .toList();

          if (commissions.isNotEmpty) {
            emit(state.copyWith(
              commissionStatus: EarningStatus.success,
              commissions: commissions,
            ));
          }
        } catch (e) {
          debugPrint("Error loading earning commissions from cache: $e");
        }
      }

      if (state.commissions.isEmpty) {
        emit(state.copyWith(commissionStatus: EarningStatus.loading));
      }
    }

    final result =
        await getCommissions(GetCommissionsParams(params: event.filterParams));

    result.fold(
      (failure) {
        if (state.commissions.isEmpty) {
          emit(state.copyWith(
              commissionStatus: EarningStatus.failure,
              errorMessage: failure.toString()));
        }
      },
      (commissions) {
        if (event.offset == 0) {
          cacheBox.put(cacheKey, commissions.map((e) => e.toJson()).toList());
        }

        bool hasReachedMax = commissions.length < event.limit;

        emit(state.copyWith(
            commissionStatus: EarningStatus.success,
            commissions: event.offset == 0
                ? commissions
                : [...state.commissions, ...commissions],
            hasReachedMaxCommissions: hasReachedMax));
      },
    );
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<EarningState> emit) {
    emit(state.copyWith(currentTabIndex: event.tabIndex));
  }

  void _onUpdateDate(UpdateDateEvent event, Emitter<EarningState> emit) {
    emit(state.copyWith(fromDate: event.fromDate, toDate: event.toDate));
  }
}
