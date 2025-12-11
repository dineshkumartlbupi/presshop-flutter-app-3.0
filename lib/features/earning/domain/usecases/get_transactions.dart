import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/earning_transaction.dart';
import '../repositories/earning_repository.dart';

class GetTransactions implements UseCase<TransactionsResult, GetTransactionsParams> {
  final EarningRepository repository;

  GetTransactions(this.repository);

  @override
  Future<Either<Failure, TransactionsResult>> call(GetTransactionsParams params) async {
    return await repository.getTransactions(params.params);
  }
}

class GetTransactionsParams extends Equatable {
  final Map<String, dynamic> params;

  const GetTransactionsParams({required this.params});

  @override
  List<Object> get props => [params];
}
