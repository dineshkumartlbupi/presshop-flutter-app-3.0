import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class GetLeaderboard extends LeaderboardEvent {
  final String countryCode;

  const GetLeaderboard(this.countryCode);

  @override
  List<Object> get props => [countryCode];
}
