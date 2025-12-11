import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.token,
    super.referralCode,
    super.currencySymbol,
    super.totalHopperArmy,
    super.avatarId,
    super.avatar,
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
    if (json['avatar_id'] is Map) {
       avId = json['avatar_id']['_id'];
       avImg = json['avatar_id']['avatar'];
    } else if (json['avatar_id'] is String) {
       avId = json['avatar_id']; // If only ID string
    }

    return UserModel(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'], 
      referralCode: json['referral_code'],
      currencySymbol: currency,
      totalHopperArmy: json['totalHopperArmy']?.toString(),
      avatarId: avId,

      avatar: avImg ?? json['avatar'],
      source: json['source'],
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
