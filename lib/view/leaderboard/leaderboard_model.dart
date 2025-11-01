class LeaderboardResponse {
  final int totalMember;
  final List<LeaderboardCountry> countryList;
  final List<Member> memberList;

  LeaderboardResponse({
    this.totalMember = 0,
    required this.countryList,
    required this.memberList,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      totalMember: json['totalMember'] ?? 0,
      countryList: (json['countryList'] as List<dynamic>?)
              ?.map((item) =>
                  LeaderboardCountry.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      memberList: (json['memberList'] as List<dynamic>?)
              ?.map((item) => Member.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LeaderboardCountry {
  final String country;
  final String countryCode;

  LeaderboardCountry({
    required this.country,
    required this.countryCode,
  });

  factory LeaderboardCountry.fromJson(Map<String, dynamic> json) {
    return LeaderboardCountry(
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

class Member {
  final String id;
  final String userName;
  final String country;
  final DateTime createdAt;
  final String totalEarnings;
  final String avatar;

  Member({
    required this.id,
    required this.userName,
    required this.country,
    required this.createdAt,
    required this.totalEarnings,
    required this.avatar,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
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
