import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entity.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();
  
  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {

  const LeaderboardLoaded(this.leaderboard);
  final LeaderboardEntity leaderboard;

  @override
  List<Object> get props => [leaderboard];
}

class LeaderboardError extends LeaderboardState {

  const LeaderboardError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
