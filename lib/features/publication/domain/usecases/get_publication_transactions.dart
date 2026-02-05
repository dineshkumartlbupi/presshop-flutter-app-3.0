import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/publication_transactions_result.dart';
import '../repositories/publication_repository.dart';

class GetPublicationTransactions implements UseCase<PublicationTransactionsResult, Map<String, dynamic>> {

  GetPublicationTransactions(this.repository);
  final PublicationRepository repository;

  @override
  Future<Either<Failure, PublicationTransactionsResult>> call(Map<String, dynamic> params) async {
    return await repository.getPublicationTransactions(params);
  }
}
