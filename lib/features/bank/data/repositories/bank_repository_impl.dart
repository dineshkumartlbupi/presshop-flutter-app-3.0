import 'package:dartz/dartz.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/bank/data/datasources/bank_remote_data_source.dart';
import 'package:presshop/features/bank/domain/entities/bank_detail.dart';
import 'package:presshop/features/bank/domain/repositories/bank_repository.dart';

class BankRepositoryImpl implements BankRepository {
  final BankRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BankRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<BankDetail>>> getBanks() async {
    if (await networkInfo.isConnected) {
      try {
        final banks = await remoteDataSource.getBanks();
        return Right(banks);
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
  Future<Either<Failure, void>> deleteBank(String id, String stripeBankId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBank(id, stripeBankId);
        return const Right(null);
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
  Future<Either<Failure, void>> setDefaultBank(String stripeBankId, bool isDefault) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.setDefaultBank(stripeBankId, isDefault);
        return const Right(null);
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
  Future<Either<Failure, String>> getStripeOnboardingUrl() async {
    if (await networkInfo.isConnected) {
      try {
        final url = await remoteDataSource.getStripeOnboardingUrl();
        return Right(url);
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
