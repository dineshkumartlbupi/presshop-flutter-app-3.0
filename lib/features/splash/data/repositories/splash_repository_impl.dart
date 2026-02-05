import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_remote_data_source.dart';
import 'package:presshop/features/splash/domain/entities/version.dart';

class SplashRepositoryImpl implements SplashRepository {

  SplashRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final SplashRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, Version>> checkAppVersion() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkAppVersion();
        return Right(result);
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
