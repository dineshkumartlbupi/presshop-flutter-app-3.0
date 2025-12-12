import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/get_publication_earning_stats.dart';
import '../../domain/usecases/get_media_houses.dart';
import '../../domain/usecases/get_publication_transactions.dart';
import 'publication_event.dart';
import 'publication_state.dart';

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final GetPublicationEarningStats getPublicationEarningStats;
  final GetMediaHouses getMediaHouses;
  final GetPublicationTransactions getPublicationTransactions;

  PublicationBloc({
    required this.getPublicationEarningStats,
    required this.getMediaHouses,
    required this.getPublicationTransactions,
  }) : super(PublicationInitial()) {
    on<LoadPublicationInitialData>(_onLoadInitialData);
    on<FilterPublicationTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadInitialData(
    LoadPublicationInitialData event,
    Emitter<PublicationState> emit,
  ) async {
    emit(PublicationLoading());

    // Call APIs in parallel
    final statsFuture = getPublicationEarningStats('publication');
    final mediaHousesFuture = getMediaHouses(NoParams());
    
    // Initial transaction load parameters
    final Map<String, dynamic> initialParams = {
      "content_id": event.contentId,
      // "limit": limit.toString(), // Add limit/offset if needed
    };
    final transactionsFuture = getPublicationTransactions(initialParams);

    final results = await Future.wait([statsFuture, mediaHousesFuture, transactionsFuture]);
    
    final statsResult = results[0] as dynamic; // casting to dynamic to handle different types
    final mediaHousesResult = results[1] as dynamic;
    final transactionsResult = results[2] as dynamic;

    // Check for failures
    // This simple check assumes all must succeed. Can be refined.
    if (statsResult.isLeft() || mediaHousesResult.isLeft() || transactionsResult.isLeft()) {
       emit(const PublicationError(message: "Failed to load data")); 
       return;
    }

    final stats = statsResult.getOrElse(() => null);
    final mediaHouses = mediaHousesResult.getOrElse(() => []);
    final transactions = transactionsResult.getOrElse(() => null);

    emit(PublicationLoaded(
      stats: stats,
      mediaHouses: mediaHouses,
      transactionsResult: transactions,
    ));
  }

  Future<void> _onFilterTransactions(
    FilterPublicationTransactions event,
    Emitter<PublicationState> emit,
  ) async {
    final currentState = state;
    if (currentState is PublicationLoaded) {
      // Show loading optionally, or keep old data
      // emit(PublicationLoading()); // Or partial loading state
      
      final result = await getPublicationTransactions(event.params);
      result.fold(
        (failure) => emit(const PublicationError(message: "Failed to filter transactions")),
        (newTransactionsResult) {
          emit(currentState.copyWith(transactionsResult: newTransactionsResult));
        }
      );
    }
  }
}
