import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/leaderboard_entity.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, LeaderboardEntity>> getLeaderboardData(String countryCode);
}
