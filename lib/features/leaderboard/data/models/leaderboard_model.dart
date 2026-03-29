import 'package:flutter/foundation.dart';
import 'package:presshop/core/utils/common_utils.dart';
import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardModel extends LeaderboardEntity {
  const LeaderboardModel({
    super.totalMember,
    required super.countryList,
    required super.memberList,
    super.currencySymbol,
  });

  factory LeaderboardModel.fromJson(dynamic json) {
    debugPrint(
        "DEBUG: LeaderboardModel.fromJson starting with type: ${json.runtimeType}");

    List<dynamic> memberListRaw = [];
    List<dynamic> countryListRaw = [];
    int totalMember = 0;
    String currencySymbol = "";

    if (json is Map<String, dynamic>) {
      debugPrint(
          "DEBUG: LeaderboardModel.fromJson JSON keys: ${json.keys.toList()}");
      Map<String, dynamic> dataMap = json;

      if (json['data'] != null) {
        if (json['data'] is Map<String, dynamic>) {
          dataMap = json['data'];
          debugPrint(
              "DEBUG: LeaderboardModel.fromJson using 'data' Map with keys: ${dataMap.keys.toList()}");
        } else if (json['data'] is List) {
          memberListRaw = json['data'];
          debugPrint(
              "DEBUG: LeaderboardModel.fromJson using 'data' List as memberListRaw, length: ${memberListRaw.length}");
        }
      }

      if (memberListRaw.isEmpty) {
        final raw = dataMap['memberList'] ??
            dataMap['members'] ??
            dataMap['member'] ??
            dataMap['leaderboard'] ??
            dataMap['list'] ??
            dataMap['membersList'] ??
            dataMap['topMembers'] ??
            dataMap['data'];
        if (raw is List) {
          memberListRaw = raw;
        }
      }

      final countries = dataMap['countryList'] ?? dataMap['countries'];
      if (countries is List) {
        countryListRaw = countries;
      }

      totalMember =
          dataMap['totalMember'] ?? dataMap['count'] ?? memberListRaw.length;
      currencySymbol = (dataMap['currency_symbol'] ??
              dataMap['currencySymbol'] ??
              dataMap['currency'] ??
              '')
          .toString();
    } else if (json is List) {
      memberListRaw = json;
      totalMember = json.length;
      debugPrint(
          "DEBUG: LeaderboardModel.fromJson JSON is a List, length: ${json.length}");
    }

    // Ensure "Global" is at the start if countryListRaw is not empty
    if (countryListRaw.isNotEmpty) {
      bool hasGlobal = countryListRaw.any((c) =>
          c is Map &&
          (c['country_code'] == '' ||
              c['countryCode'] == '' ||
              c['country'] == 'Global'));
      if (!hasGlobal) {
        countryListRaw.insert(0, {'country': 'Global', 'country_code': ''});
        debugPrint("DEBUG: LeaderboardModel.fromJson Prepended Global country");
      }
    }

    return LeaderboardModel(
      totalMember: totalMember,
      countryList: countryListRaw
          .map((item) =>
              LeaderboardCountryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      memberList: memberListRaw
          .map((item) => MemberModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      currencySymbol: currencySymbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMember': totalMember,
      'countryList': countryList
          .map((e) => (e as LeaderboardCountryModel).toJson())
          .toList(),
      'memberList': memberList.map((e) => (e as MemberModel).toJson()).toList(),
    };
  }
}

class LeaderboardCountryModel extends LeaderboardCountryEntity {
  const LeaderboardCountryModel({
    required super.country,
    required super.countryCode,
  });

  factory LeaderboardCountryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardCountryModel(
      country: (json['country'] ?? '').toString(),
      countryCode:
          (json['country_code'] ?? json['countryCode'] ?? '').toString(),
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
    String userName = (json['user_name'] ?? '').toString();
    if (userName.isEmpty) {
      userName =
          "${json['first_name'] ?? ''} ${json['last_name'] ?? ''}".trim();
    }
    if (userName.isEmpty) {
      userName = (json['userName'] ?? json['full_name'] ?? json['name'] ?? '')
          .toString();
    }

    String avatar = (json['avatar'] ?? json['profile_image'] ?? '').toString();

    // Check nested objects if empty
    if (userName.isEmpty || avatar.isEmpty) {
      final nestedUser = json['hopper_id'] ??
          json['user_id'] ??
          json['hopper_details'] ??
          json['user_details'];
      if (nestedUser != null && nestedUser is Map) {
        if (userName.isEmpty) {
          userName = (nestedUser['user_name'] ??
                  nestedUser['userName'] ??
                  nestedUser['full_name'] ??
                  nestedUser['name'] ??
                  '')
              .toString();
        }
        if (avatar.isEmpty) {
          avatar = (nestedUser['avatar'] ?? nestedUser['profile_image'] ?? '')
              .toString();
        }
      }
    }

    if (avatar.isNotEmpty && !avatar.startsWith("http")) {
      const String mediaBaseUrl =
          "https://dev-presshope.s3.eu-west-2.amazonaws.com/public/";
      // Try to guess folder
      final String folder = avatar.contains("/") ? "" : "avatarImages/";
      avatar = "$mediaBaseUrl$folder$avatar";
    }

    return MemberModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userName: userName,
      country: (json['country'] ?? '').toString(),
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse((json['createdAt'] ?? json['created_at']).toString())
          : DateTime.now(),
      totalEarnings: double.tryParse(
                  (json['totalEarnings'] ?? json['total_earnings'] ?? 0)
                      .toString())
              ?.toStringAsFixed(2) ??
          '0.00',
      avatar: avatar.isEmpty ? "" : fixS3Url(avatar),
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
