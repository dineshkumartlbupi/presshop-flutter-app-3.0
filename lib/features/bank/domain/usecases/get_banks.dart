import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';

class GetBanks implements UseCase<List<BankDetail>, NoParams> {
  final BankRepository repository;

  GetBanks(this.repository);

  @override
  Future<Either<Failure, List<BankDetail>>> call(NoParams params) async {
    return await repository.getBanks();
  }
}
