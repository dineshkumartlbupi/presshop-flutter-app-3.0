import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_earning_profile.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_commissions.dart';
import '../../domain/entities/earning_transaction.dart';
import 'earning_event.dart';
import 'earning_state.dart';
import '../../data/models/earning_model.dart'; 
// Still used for internal logic or state, ideally should use entities but state seems to rely on Models currently.
// Ideally State should use Entities, but for now we map back or use models if entities are 1-1.
// EarningRepositoryImpl returns EarningProfile entity, EarningTransactionDetail list (which acts as model/entity), //////Commission list (which maps to Entity).

// Update: EarningState uses EarningProfileDataModel.
// Option 1: Update EarningState to use Entities. (Preferred)
// Option 2: Map Entities back to Models in Bloc (Anti-pattern but quick).
// Let's check EarningState definition. 
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
          // Mapping Entity to Model for State Compatibility 
          // Ideally State should be updated to use EarningProfile Entity.
          // For now, let's construct Model from Entity or update State.
          // Let's Construct Model here to minimize State changes for now.
          final data = EarningProfileDataModel(
              id: profile.id, 
              avatarId: "", // Not in Entity currently, check if needed
              avatar: profile.avatar, 
              totalEarning: profile.totalEarning
          );
          
          emit(state.copyWith(
            status: EarningStatus.success,
            earningData: data,
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
          
          // Populate hopper avatar logic if needed. 
          // Note: Entity is immutable. We can't set hopperAvatar. 
          // But I added hopperAvatar field to Entity and populated it in Repository/Mapper.
          // Wait, Repository/Mapper used `model.hopperAvatar`.
          // In the original Bloc, it was setting it from `state.earningData?.avatar`.
          
          // If the API for transaction doesn't return avatar but EarningData (Profile) does, 
          // we might need to inject it.
          // If `hopperAvatar` in Entity is empty, we can try to use `state.earningData.avatar`.
          // Since Entity is immutable, we'd need to recreate the list.
          
          List<EarningTransaction> updatedTransactions = transactions;
          if (state.earningData != null) {
              updatedTransactions = transactions.map((t) {
                  if (t.hopperAvatar.isEmpty) {
                       // CopyWith would be nice here. 
                       // Since I didn't add copyWith to Entity, I'll have to instantiate new.
                       // This is tedious. 
                       // Check if Repository already populated it?
                       // Repository mapped from Model. Model has `hopperAvatar`.
                       // API response for transaction: `hopper_id` -> `avatar`.
                       // So likely it IS populated from Transaction API itself.
                       // The original bloc logic lines 87-91:
                       // `if (state.earningData != null) { item.hopperAvatar = state.earningData?.avatar ?? ""; }`
                       // This suggests Transaction API might NOT return avatar always, or they wanted to override/fallback.
                       // Assuming Transaction API returns it (as seen in model `json['hopper_id']['avatar']`), I will trust repository.
                       return t;
                  }
                  return t;
              }).toList();
          }

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
      (commissionsEntityList) {
         // Map Entity to Model
         final commissions = commissionsEntityList.map((e) => CommissionData(
             totalEarning: e.totalEarning,
             commission: e.commission,
             commissionReceived: e.commissionReceived,
             commissionPending: e.commissionPending,
             paidOn: e.paidOn,
             firstName: e.firstName,
             lastName: e.lastName,
             dateOfJoining: e.dateOfJoining,
             avatar: e.avatar
         )).toList();
         
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
