import 'package:equatable/equatable.dart';
import 'package:presshop/features/profile/domain/entities/profile_data.dart'
    as entity;

class UserProfileResponse extends Equatable {
  const UserProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    var userData = json['data'] ?? json['userData'];
    if (userData == null) {
      if (json.containsKey('email') ||
          json.containsKey('first_name') ||
          json.containsKey('profile_image')) {
        userData = json;
      } else {
        userData = {};
      }
    } else if (userData is Map &&
        userData.containsKey('data') &&
        userData['data'] is Map) {
      userData = userData['data'];
    }

    if (userData is! Map) {
      userData = {};
    }

    return UserProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileModel.fromJson(Map<String, dynamic>.from(userData)),
    );
  }
  final bool success;
  final String message;
  final UserProfileModel data;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}

class UserProfileModel extends Equatable {
  const UserProfileModel({
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
    required this.avatar,
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
    required this.stripeStatus,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
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
      profileImage: _extractProfileImage(json),
      avatar: _extractAvatar(json),
      isVerified: json['isVerified'] ?? false,
      isOnboard: json['is_onboard'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      totalEarnings: json['totalEarnings'] ?? 0,
      totalHopperArmy: json['totalHopperArmy'] ?? 0,
      location: LocationModel.fromJson(Map<String, dynamic>.from(
          json['location'] is Map ? json['location'] : {})),
      preferredCurrencySign: PreferredCurrencySignModel.fromJson(
          Map<String, dynamic>.from(json['preferred_currency_sign'] is Map
              ? json['preferred_currency_sign']
              : {})),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      lastLogin: DateTime.tryParse(json['lastLogin'] ?? '') ?? DateTime.now(),
      stripeStatus: json['stripeStatus'] != null
          ? (json['stripeStatus'] is Map
              ? StripeStatusModel.fromJson(Map<String, dynamic>.from(json['stripeStatus']))
              : StripeStatusModel(
                  stripeStatusActive:
                      (['1', 'true'].contains(json['stripeStatus'].toString()))
                          ? "1"
                          : "0",
                  stripeStatusReason: ""))
          : const StripeStatusModel(
              stripeStatusActive: "0", stripeStatusReason: ""),
    );
  }

  static String _extractAvatar(Map<String, dynamic> json) {
    String tempAvatar = json["avatar"]?.toString() ?? "";
    if (json["avatarData"] is Map) {
      tempAvatar = json["avatarData"]["avatar"]?.toString() ?? tempAvatar;
    }
    return tempAvatar;
  }

  static String _extractProfileImage(Map<String, dynamic> json) {
    return json["profile_image"]?.toString() ??
        json["profileImage"]?.toString() ??
        "";
  }

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
  final String avatar;
  final bool isVerified;
  final bool isOnboard;
  final bool isDeleted;
  final double latitude;
  final double longitude;
  final dynamic totalEarnings;
  final int totalHopperArmy;
  final LocationModel location;
  final PreferredCurrencySignModel preferredCurrencySign;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;
  final StripeStatusModel stripeStatus;

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
      'avatar': avatar,
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
      'stripeStatus': stripeStatus.toJson(),
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
      avatar: avatar,
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
      stripeStatus: stripeStatus.toEntity(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        userName,
        role,
        status,
        hopperStatus,
        chatStatus,
        profileImage,
        avatar,
        isVerified,
        isOnboard,
        isDeleted,
        latitude,
        longitude,
        totalEarnings,
        totalHopperArmy,
        location,
        preferredCurrencySign,
        createdAt,
        updatedAt,
        lastLogin,
        stripeStatus,
      ];
}

class LocationModel extends Equatable {
  const LocationModel({
    required this.type,
    required this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
  final String type;
  final List<double> coordinates;

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

  @override
  List<Object?> get props => [type, coordinates];
}

class StripeStatusModel extends Equatable {

  const StripeStatusModel({
    required this.stripeStatusActive,
    required this.stripeStatusReason,
  });

  factory StripeStatusModel.fromJson(Map<String, dynamic> json) {
    bool isActive = json['status'] == true ||
        json['status'] == 1 ||
        json['status'] == '1' ||
        json['status'] == 'true';
    return StripeStatusModel(
      stripeStatusActive: isActive ? "1" : "0",
      stripeStatusReason: json['reason'] ?? "",
    );
  }
  final String stripeStatusActive;
  final String stripeStatusReason;

  Map<String, dynamic> toJson() {
    return {
      'status': stripeStatusActive,
      'reason': stripeStatusReason,
    };
  }

  entity.StripeStatus toEntity() {
    return entity.StripeStatus(
      stripeStatusActive: stripeStatusActive,
      stripeStatusReason: stripeStatusReason,
    );
  }

  @override
  List<Object?> get props => [stripeStatusActive, stripeStatusReason];
}

class PreferredCurrencySignModel extends Equatable {
  const PreferredCurrencySignModel({
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
  final String symbol;
  final String code;
  final String name;
  final String countryName;
  final String countryCode;
  final String dialCode;

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

  @override
  List<Object?> get props => [
        symbol,
        code,
        name,
        countryName,
        countryCode,
        dialCode,
      ];
}
