import 'package:equatable/equatable.dart';

class LeaderboardEntity extends Equatable {
  const LeaderboardEntity({
    this.totalMember = 0,
    required this.countryList,
    required this.memberList,
    this.currencySymbol = "",
  });
  final int totalMember;
  final List<LeaderboardCountryEntity> countryList;
  final List<MemberEntity> memberList;
  final String currencySymbol;

  @override
  List<Object?> get props => [totalMember, countryList, memberList];

  LeaderboardEntity copyWith({
    int? totalMember,
    List<LeaderboardCountryEntity>? countryList,
    List<MemberEntity>? memberList,
    String? currencySymbol,
  }) {
    return LeaderboardEntity(
      totalMember: totalMember ?? this.totalMember,
      countryList: countryList ?? this.countryList,
      memberList: memberList ?? this.memberList,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMember': totalMember,
      'currency_symbol': currencySymbol,
      'countryList': countryList.map((e) => e.toJson()).toList(),
      'memberList': memberList.map((e) => e.toJson()).toList(),
    };
  }
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

  LeaderboardCountryEntity copyWith({
    String? country,
    String? countryCode,
  }) {
    return LeaderboardCountryEntity(
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'countryCode': countryCode,
    };
  }
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
  List<Object?> get props =>
      [id, userName, country, createdAt, totalEarnings, avatar];

  MemberEntity copyWith({
    String? id,
    String? userName,
    String? country,
    DateTime? createdAt,
    String? totalEarnings,
    String? avatar,
  }) {
    return MemberEntity(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      avatar: avatar ?? this.avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'country': country,
      'created_at': createdAt.toIso8601String(),
      'total_earnings': totalEarnings,
      'avatar': avatar,
    };
  }
}
