import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';

class SetDefaultBank implements UseCase<void, SetDefaultBankParams> {

  SetDefaultBank(this.repository);
  final BankRepository repository;

  @override
  Future<Either<Failure, void>> call(SetDefaultBankParams params) async {
    return await repository.setDefaultBank(
        params.stripeBankId, params.isDefault);
  }
}

class SetDefaultBankParams {

  const SetDefaultBankParams(
      {required this.stripeBankId, required this.isDefault});
  final String stripeBankId;
  final bool isDefault;
}
