import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_datasource.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LeaderboardEntity>> getLeaderboardData(String countryCode) async {
    try {
      final remoteData = await remoteDataSource.getLeaderboardData(countryCode);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
