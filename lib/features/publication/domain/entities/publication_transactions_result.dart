import 'package:equatable/equatable.dart';
import 'package:presshop/features/earning/domain/entities/earning_transaction.dart';

class PublicationTransactionsResult extends Equatable {
  final List<EarningTransaction> transactions;
  final String publicationCount;
  final String totalAmount;

  const PublicationTransactionsResult({
    required this.transactions,
    required this.publicationCount,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [transactions, publicationCount, totalAmount];
}
