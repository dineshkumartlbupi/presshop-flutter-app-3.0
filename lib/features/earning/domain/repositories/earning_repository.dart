import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/commission.dart';
import '../entities/earning_profile.dart';
import '../entities/earning_transaction.dart';

abstract class EarningRepository {
  Future<Either<Failure, EarningProfile>> getEarningProfile(String year, String month);
  Future<Either<Failure, TransactionsResult>> getTransactions(Map<String, dynamic> params);
  Future<Either<Failure, List<Commission>>> getCommissions(Map<String, dynamic> params);
}
