import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import '../repositories/content_repository.dart';

class GetContentTransactions
    implements
        UseCase<List<EarningTransactionDetail>, GetContentTransactionsParams> {
  final ContentRepository repository;

  GetContentTransactions(this.repository);

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>> call(
      GetContentTransactionsParams params) async {
    return await repository.getContentTransactions(
        params.contentId, params.limit, params.offset,
        showLoader: params.showLoader);
  }
}

class GetContentTransactionsParams extends Equatable {
  final String contentId;
  final int limit;
  final int offset;
  final bool showLoader;

  const GetContentTransactionsParams({
    required this.contentId,
    required this.limit,
    required this.offset,
    this.showLoader = true,
  });

  @override
  @override
  List<Object?> get props => [contentId, limit, offset, showLoader];
}
