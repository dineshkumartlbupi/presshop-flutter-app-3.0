import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/network_info.dart';
import '../../domain/entities/admin_contact_info.dart';
import '../../domain/repositories/account_settings_repository.dart';
import '../../domain/entities/faq.dart';
import '../../../publish/domain/entities/content_category.dart';
import '../datasources/account_settings_remote_datasource.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {

  AccountSettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final AccountSettingsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, bool>> deleteAccount(
      Map<String, String> reason) async {
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

  @override
  Future<Either<Failure, List<FAQ>>> getFAQs(
      String category, int offset, int limit) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getFAQs(category, offset, limit);
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
  Future<Either<Failure, List<FAQ>>> getPriceTips(
      String category, int offset, int limit) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await remoteDataSource.getPriceTips(category, offset, limit);
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
  Future<Either<Failure, List<ContentCategory>>> getFAQCategories(
      String type) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getFAQCategories(type);
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
