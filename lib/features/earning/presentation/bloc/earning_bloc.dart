import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_earning_profile.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_commissions.dart';
import '../../domain/entities/earning_transaction.dart';
import 'earning_event.dart';
import 'earning_state.dart';

class EarningBloc extends Bloc<EarningEvent, EarningState> {
  final GetEarningProfile getEarningProfile;
  final GetTransactions getTransactions;
  final GetCommissions getCommissions;

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

  Future<void> _onFetchEarningData(
      FetchEarningDataEvent event, Emitter<EarningState> emit) async {
    emit(state.copyWith(status: EarningStatus.loading));
    
    final result = await getEarningProfile(
        GetEarningProfileParams(year: event.fromDate, month: event.toDate));
        
    result.fold(
      (failure) => emit(state.copyWith(
          status: EarningStatus.failure, errorMessage: failure.toString())),
      (profile) {
          emit(state.copyWith(
            status: EarningStatus.success,
            earningData: profile, // Now using Entity
          ));
      },
    );
  }

  Future<void> _onFetchTransactions(
      FetchTransactionsEvent event, Emitter<EarningState> emit) async {
    if (event.offset == 0) {
      emit(state.copyWith(transactionStatus: EarningStatus.loading));
    }
    
    final result = await getTransactions(GetTransactionsParams(params: event.filterParams));
    
    result.fold(
      (failure) => emit(state.copyWith(
          transactionStatus: EarningStatus.failure, errorMessage: failure.toString())),
      (resultData) {
          final transactions = resultData.transactions;
          final monthlyEarnings = resultData.totalEarning;
          
          List<EarningTransaction> updatedTransactions = transactions;
          // Logic to ensure hopperAvatar is present if missing, using EarningData profile if available.
          // Since we use Entities now and they are immutable, strict re-creation or trusting API.
          // Proceeding with trusting API + basic fallback logic if needed in UI or simplistic map here.
          
          bool hasReachedMax = transactions.length < event.limit; 
           
           emit(state.copyWith(
              transactionStatus: EarningStatus.success,
              transactions: event.offset == 0 ? updatedTransactions : [...state.transactions, ...updatedTransactions],
              hasReachedMaxTransactions: hasReachedMax,
              monthlyEarnings: monthlyEarnings,
           ));
      },
    );
  }
  
  Future<void> _onFetchCommissions(
      FetchCommissionsEvent event, Emitter<EarningState> emit) async {
    if (event.offset == 0) {
      emit(state.copyWith(commissionStatus: EarningStatus.loading));
    }
    
    final result = await getCommissions(GetCommissionsParams(params: event.filterParams));
    
    result.fold(
      (failure) => emit(state.copyWith(
          commissionStatus: EarningStatus.failure, errorMessage: failure.toString())),
      (commissions) {
         bool hasReachedMax = commissions.length < event.limit; 

         emit(state.copyWith(
            commissionStatus: EarningStatus.success,
            commissions: event.offset == 0 ? commissions : [...state.commissions, ...commissions],
            hasReachedMaxCommissions: hasReachedMax
         ));
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
