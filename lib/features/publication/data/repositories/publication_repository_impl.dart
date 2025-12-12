import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/api/network_info.dart';
import '../../domain/repositories/publication_repository.dart';
import '../../domain/entities/media_house.dart';
import '../../domain/entities/publication_earning_stats.dart';
import '../../domain/entities/publication_transactions_result.dart';
import '../datasources/publication_remote_data_source.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final PublicationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PublicationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PublicationEarningStats>> getEarningStats(String type) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEarningStats(type);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<MediaHouse>>> getMediaHouses() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMediaHouses();
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, PublicationTransactionsResult>> getPublicationTransactions(Map<String, dynamic> params) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getPublicationTransactions(params);
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
