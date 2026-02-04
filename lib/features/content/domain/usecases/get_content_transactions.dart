import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import '../repositories/content_repository.dart';

class GetContentTransactions
    implements
        UseCase<List<EarningTransactionDetail>, GetContentTransactionsParams> {

  GetContentTransactions(this.repository);
  final ContentRepository repository;

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>> call(
      GetContentTransactionsParams params) async {
    return await repository.getContentTransactions(
        params.contentId, params.limit, params.offset);
  }
}

class GetContentTransactionsParams extends Equatable {

  const GetContentTransactionsParams({
    required this.contentId,
    required this.limit,
    required this.offset,
  });
  final String contentId;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [contentId, limit, offset];
}
