import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/splash/domain/entities/version.dart';

abstract class SplashRepository {
  Future<Either<Failure, Version>> checkAppVersion();
}
