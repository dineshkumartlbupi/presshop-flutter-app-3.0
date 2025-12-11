import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/admin_contact_info.dart';
import '../../domain/repositories/account_settings_repository.dart';
import '../datasources/account_settings_remote_datasource.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  final AccountSettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AccountSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> deleteAccount(Map<String, String> reason) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteAccount(reason);
        return Right(result);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AdminContactInfo>> getAdminContactInfo() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getAdminContactInfo();
        return Right(result);
      } on Failure catch (failure) {
        return Left(failure);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
