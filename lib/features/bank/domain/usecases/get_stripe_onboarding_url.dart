import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';

class GetStripeOnboardingUrl implements UseCase<String, NoParams> {
  GetStripeOnboardingUrl(this.repository);
  final BankRepository repository;

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getStripeOnboardingUrl();
  }
}
