import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/leaderboard_entity.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboardData {
  GetLeaderboardData(this.repository);
  final LeaderboardRepository repository;

  Future<Either<Failure, LeaderboardEntity>> call(String countryCode) async {
    return await repository.getLeaderboardData(countryCode);
  }
}
