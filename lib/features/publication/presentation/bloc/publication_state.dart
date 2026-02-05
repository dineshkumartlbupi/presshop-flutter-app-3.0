import 'package:equatable/equatable.dart';
import '../../domain/entities/media_house.dart';
import '../../domain/entities/publication_earning_stats.dart';
import '../../domain/entities/publication_transactions_result.dart';

abstract class PublicationState extends Equatable {
  const PublicationState();
  
  @override
  List<Object> get props => [];
}

class PublicationInitial extends PublicationState {}

class PublicationLoading extends PublicationState {}

class PublicationLoaded extends PublicationState {

  const PublicationLoaded({
    required this.stats,
    required this.mediaHouses,
    required this.transactionsResult,
  });
  final PublicationEarningStats stats;
  final List<MediaHouse> mediaHouses;
  final PublicationTransactionsResult transactionsResult;

  @override
  List<Object> get props => [stats, mediaHouses, transactionsResult];

  PublicationLoaded copyWith({
    PublicationEarningStats? stats,
    List<MediaHouse>? mediaHouses,
    PublicationTransactionsResult? transactionsResult,
  }) {
    return PublicationLoaded(
      stats: stats ?? this.stats,
      mediaHouses: mediaHouses ?? this.mediaHouses,
      transactionsResult: transactionsResult ?? this.transactionsResult,
    );
  }
}

class PublicationError extends PublicationState {
  const PublicationError({required this.message});
  final String message;
  @override
  List<Object> get props => [message];
}
