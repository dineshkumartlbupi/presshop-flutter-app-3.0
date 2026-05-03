import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';

abstract class BankRepository {
  Future<Either<Failure, List<BankDetail>>> getBanks();
  Future<Either<Failure, void>> deleteBank(String id, String stripeBankId);
  Future<Either<Failure, void>> setDefaultBank(String stripeBankId, bool isDefault);
  Future<Either<Failure, String>> getStripeOnboardingUrl();
}
