import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyReferralCode implements UseCase<Map<String, dynamic>, String> {
  final AuthRepository repository;

  VerifyReferralCode(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String code) async {
    return await repository.verifyReferralCode(code);
  }
}
