import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetContentTransactionDetails
    implements
        UseCase<List<EarningTransactionDetail>, ContentTransactionParams> {

  GetContentTransactionDetails(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, List<EarningTransactionDetail>>> call(
      ContentTransactionParams params) async {
    return await repository.getContentTransactionDetails(
        params.roomId, params.mediaHouseId);
  }
}

class ContentTransactionParams extends Equatable {

  const ContentTransactionParams({
    required this.roomId,
    required this.mediaHouseId,
  });
  final String roomId;
  final String mediaHouseId;

  @override
  List<Object> get props => [roomId, mediaHouseId];
}
