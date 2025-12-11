import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    super.totalMember,
    required super.countryList,
    required super.memberList,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      totalMember: json['totalMember'] ?? 0,
      countryList: (json['countryList'] as List<dynamic>?)
              ?.map((item) => LeaderboardCountryModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      memberList: (json['memberList'] as List<dynamic>?)
              ?.map((item) => MemberModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LeaderboardCountryModel extends LeaderboardCountryEntity {
  const LeaderboardCountryModel({
    required super.country,
    required super.countryCode,
  });

  factory LeaderboardCountryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardCountryModel(
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'country_code': countryCode,
    };
  }
}

class MemberModel extends MemberEntity {
  const MemberModel({
    required super.id,
    required super.userName,
    required super.country,
    required super.createdAt,
    required super.totalEarnings,
    required super.avatar,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['_id'] ?? '',
      userName: json['user_name'] ?? '',
      country: json['country'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalEarnings: double.parse((json['totalEarnings'] ?? 0).toString())
          .toStringAsFixed(2),
      avatar: json['avatar'] ?? '',
    );
  }
}
