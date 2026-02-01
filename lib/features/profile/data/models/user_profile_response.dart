import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/features/profile/domain/entities/profile_data.dart'
    as entity;

class UserProfileResponse {
  final bool success;
  final String message;
  final UserProfileModel data;

  UserProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    var userData = json['data'] ?? json['userData'] ?? {};
    if (userData is Map &&
        userData.containsKey('data') &&
        userData['data'] is Map) {
      userData = userData['data'];
    }
    return UserProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileModel.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String userName;
  final String role;
  final String status;
  final String hopperStatus;
  final String chatStatus;
  final String profileImage;
  final bool isVerified;
  final bool isOnboard;
  final bool isDeleted;
  final double latitude;
  final double longitude;
  final int totalEarnings;
  final int totalHopperArmy;
  final LocationModel location;
  final PreferredCurrencySignModel preferredCurrencySign;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

  UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.userName,
    required this.role,
    required this.status,
    required this.hopperStatus,
    required this.chatStatus,
    required this.profileImage,
    required this.isVerified,
    required this.isOnboard,
    required this.isDeleted,
    required this.latitude,
    required this.longitude,
    required this.totalEarnings,
    required this.totalHopperArmy,
    required this.location,
    required this.preferredCurrencySign,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String extractImage(Map<String, dynamic> json) {
      String tempAvatar = "";
      if (json["avatarData"] is Map) {
        tempAvatar = json["avatarData"]["avatar"]?.toString() ?? "";
      } else if (json["avatarData"] is String &&
          json["avatarData"].toString().startsWith("http")) {
        tempAvatar = json["avatarData"];
      }

      if (tempAvatar.isEmpty) {
        tempAvatar = json["avatar"]?.toString() ??
            json["profile_image"]?.toString() ??
            json["profileImage"]?.toString() ??
            "";
      }

      if (tempAvatar.isNotEmpty && !tempAvatar.startsWith("http")) {
        const String mediaBaseUrl =
            "https://dev-presshope.s3.eu-west-2.amazonaws.com/public/";
        final String folder = tempAvatar.contains("/") ? "" : "avatarImages/";
        tempAvatar = "$mediaBaseUrl$folder$tempAvatar";
      }
      return fixS3Url(tempAvatar);
    }

    return UserProfileModel(
      id: json['id'] ?? json['_id'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobile_number'] ?? '',
      userName: json['user_name'] ?? json['username'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      hopperStatus: json['hopperStatus'] ?? '',
      chatStatus: json['chat_status'] ?? '',
      profileImage: extractImage(json),
      isVerified: json['isVerified'] ?? false,
      isOnboard: json['is_onboard'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      totalEarnings: json['totalEarnings'] ?? 0,
      totalHopperArmy: json['totalHopperArmy'] ?? 0,
      location: LocationModel.fromJson(json['location'] ?? {}),
      preferredCurrencySign: PreferredCurrencySignModel.fromJson(
          json['preferred_currency_sign'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'user_name': userName,
      'role': role,
      'status': status,
      'hopperStatus': hopperStatus,
      'chat_status': chatStatus,
      'profile_image': profileImage,
      'isVerified': isVerified,
      'is_onboard': isOnboard,
      'is_deleted': isDeleted,
      'latitude': latitude,
      'longitude': longitude,
      'totalEarnings': totalEarnings,
      'totalHopperArmy': totalHopperArmy,
      'location': location.toJson(),
      'preferred_currency_sign': preferredCurrencySign.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  entity.ProfileData toEntity() {
    return entity.ProfileData(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      userName: userName,
      role: role,
      status: status,
      hopperStatus: hopperStatus,
      chatStatus: chatStatus,
      profileImage: profileImage,
      isVerified: isVerified,
      isOnboard: isOnboard,
      isDeleted: isDeleted,
      latitude: latitude,
      longitude: longitude,
      totalEarnings: totalEarnings,
      totalHopperArmy: totalHopperArmy,
      location: location.toEntity(),
      preferredCurrencySign: preferredCurrencySign.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
    );
  }
}

class LocationModel {
  final String type;
  final List<double> coordinates;

  LocationModel({
    required this.type,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: List<double>.from(
        (json['coordinates'] ?? []).map((e) => e.toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  entity.Location toEntity() {
    return entity.Location(
      type: type,
      coordinates: coordinates,
    );
  }
}

class PreferredCurrencySignModel {
  final String symbol;
  final String code;
  final String name;
  final String countryName;
  final String countryCode;
  final String dialCode;

  PreferredCurrencySignModel({
    required this.symbol,
    required this.code,
    required this.name,
    required this.countryName,
    required this.countryCode,
    required this.dialCode,
  });

  factory PreferredCurrencySignModel.fromJson(Map<String, dynamic> json) {
    return PreferredCurrencySignModel(
      symbol: json['symbol'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      countryName: json['country_name'] ?? '',
      countryCode: json['country_code'] ?? '',
      dialCode: json['dial_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'code': code,
      'name': name,
      'country_name': countryName,
      'country_code': countryCode,
      'dial_code': dialCode,
    };
  }

  entity.PreferredCurrencySign toEntity() {
    return entity.PreferredCurrencySign(
      symbol: symbol,
      code: code,
      name: name,
      countryName: countryName,
      countryCode: countryCode,
      dialCode: dialCode,
    );
  }
}
