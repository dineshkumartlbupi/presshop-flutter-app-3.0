import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.token,
    super.refreshToken, // Added refreshToken to constructor
    super.referralCode,
    super.currencySymbol,
    super.totalHopperArmy,
    super.avatarId,
    super.avatar,
    super.profileImage,
    super.source,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse currency symbol which might be nested map or null
    String? currency;
    if (json['preferred_currency_sign'] is Map) {
      currency = json['preferred_currency_sign']['symbol'];
    } else if (json['preferred_currency_sign'] is String) {
      currency = json['preferred_currency_sign'];
    }

    String? avId;
    String? avImg;

    // Support avatar_id (snake_case) or avatarData (camelCase)
    final avatarMap = json['avatarData'] ?? json['avatar_id'];

    if (avatarMap is Map) {
      avId = (avatarMap['_id'] ?? avatarMap['id'])?.toString();
      avImg = avatarMap['avatar']?.toString();
    } else if (avatarMap is String) {
      avId = avatarMap;
    }

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? json['access_token'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      referralCode: json['referral_code'],
      currencySymbol: currency,
      totalHopperArmy: json['totalHopperArmy']?.toString(),
      avatarId: avId,
      avatar: avImg ?? json['avatar'],
      profileImage: json['profile_image'] ?? json['profileImage'],
      source: json['source'] ?? json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'token': token,
    };
  }
}
