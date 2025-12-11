import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';

class DeleteBank implements UseCase<void, DeleteBankParams> {
  final BankRepository repository;

  DeleteBank(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBankParams params) async {
    return await repository.deleteBank(params.id, params.stripeBankId);
  }
}

class DeleteBankParams {
  final String id;
  final String stripeBankId;

  DeleteBankParams({required this.id, required this.stripeBankId});
}
