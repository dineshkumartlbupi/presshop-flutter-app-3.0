import 'package:dartz/dartz.dart';

import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetTaskTransactionDetails
    implements UseCase<List<EarningTransactionDetail>, String> {
  final TaskRepository repository;

  GetTaskTransactionDetails(this.repository);

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>> call(
      String transactionId) async {
    return await repository.getTaskTransactionDetails(transactionId);
  }
}
