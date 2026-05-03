import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class GetLeaderboard extends LeaderboardEvent {
  const GetLeaderboard(this.countryCode);
  final String countryCode;

  @override
  List<Object> get props => [countryCode];
}
