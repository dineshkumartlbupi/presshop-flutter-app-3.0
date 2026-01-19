import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';

abstract class SplashRepository {
  Future<Either<Failure, Map<String, dynamic>>> checkAppVersion();
}
