import 'package:equatable/equatable.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/earning_profile.dart';
import '../../domain/entities/earning_transaction.dart';

enum EarningStatus { initial, loading, success, failure, empty }

class EarningState extends Equatable {
  final EarningStatus status;
  final EarningStatus transactionStatus;
  final EarningStatus commissionStatus;
  
  final EarningProfile? earningData;
  final List<EarningTransaction> transactions;
  final List<Commission> commissions;
  
  final bool hasReachedMaxTransactions;
  final bool hasReachedMaxCommissions;
  
  final String errorMessage;
  final int currentTabIndex;
  
  final String fromDate;
  final String toDate;
  final String monthlyEarnings;

  const EarningState({
    this.status = EarningStatus.initial,
    this.transactionStatus = EarningStatus.initial,
    this.commissionStatus = EarningStatus.initial,
    this.earningData,
    this.transactions = const [],
    this.commissions = const [],
    this.hasReachedMaxTransactions = false,
    this.hasReachedMaxCommissions = false,
    this.errorMessage = '',
    this.currentTabIndex = 0,
    this.fromDate = '',
    this.toDate = '',
    this.monthlyEarnings = '',
  });
  
  EarningState copyWith({
      EarningStatus? status,
      EarningStatus? transactionStatus,
      EarningStatus? commissionStatus,
      EarningProfile? earningData,
      List<EarningTransaction>? transactions,
      List<Commission>? commissions,
      bool? hasReachedMaxTransactions,
      bool? hasReachedMaxCommissions,
      String? errorMessage,
      int? currentTabIndex,
      String? fromDate,
      String? toDate,
      String? monthlyEarnings,
  }) {
      return EarningState(
          status: status ?? this.status,
          transactionStatus: transactionStatus ?? this.transactionStatus,
          commissionStatus: commissionStatus ?? this.commissionStatus,
          earningData: earningData ?? this.earningData,
          transactions: transactions ?? this.transactions, 
          commissions: commissions ?? this.commissions,
          hasReachedMaxTransactions: hasReachedMaxTransactions ?? this.hasReachedMaxTransactions,
          hasReachedMaxCommissions: hasReachedMaxCommissions ?? this.hasReachedMaxCommissions,
          errorMessage: errorMessage ?? this.errorMessage,
          currentTabIndex: currentTabIndex ?? this.currentTabIndex,
          fromDate: fromDate ?? this.fromDate,
          toDate: toDate ?? this.toDate,
          monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      );
  }

  @override
  List<Object?> get props => [
    status, transactionStatus, commissionStatus, earningData, transactions, commissions,
    hasReachedMaxTransactions, hasReachedMaxCommissions, errorMessage, currentTabIndex, fromDate, toDate, monthlyEarnings
  ];
}
