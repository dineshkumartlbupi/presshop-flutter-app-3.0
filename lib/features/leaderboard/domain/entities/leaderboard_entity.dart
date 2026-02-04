import 'package:equatable/equatable.dart';

class LeaderboardEntity extends Equatable {

  const LeaderboardEntity({
    this.totalMember = 0,
    required this.countryList,
    required this.memberList,
  });
  final int totalMember;
  final List<LeaderboardCountryEntity> countryList;
  final List<MemberEntity> memberList;

  @override
  List<Object?> get props => [totalMember, countryList, memberList];
}

class LeaderboardCountryEntity extends Equatable {

  const LeaderboardCountryEntity({
    required this.country,
    required this.countryCode,
  });
  final String country;
  final String countryCode;

  @override
  List<Object?> get props => [country, countryCode];
}

class MemberEntity extends Equatable {

  const MemberEntity({
    required this.id,
    required this.userName,
    required this.country,
    required this.createdAt,
    required this.totalEarnings,
    required this.avatar,
  });
  final String id;
  final String userName;
  final String country;
  final DateTime createdAt;
  final String totalEarnings;
  final String avatar;

  @override
  List<Object?> get props => [id, userName, country, createdAt, totalEarnings, avatar];
}
