import 'package:presshop/core/core_export.dart';
import '../../domain/entities/profile_data.dart';

class ProfileDataModel extends ProfileData {
  const ProfileDataModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.userName,
    required super.email,
    required super.phone,
    super.profileImage,
    super.address,
    super.city,
    super.country,
    super.postalCode,
    super.latitude,
    super.longitude,
    super.dob,
    super.bio,
    super.currencySymbol,
    super.totalEarnings,
    super.apartment,
    super.countryCode,
    super.avatarId,
    super.sourceMap,
    super.joinedDate,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userName: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobile_number'] ?? '',
      profileImage: json['profile_image'] ?? json['avatar'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      dob: json['dob'],
      bio: json['bio'],
      currencySymbol: json['preferred_currency_sign'] is Map
          ? json['preferred_currency_sign']['symbol']
          : json['preferred_currency_sign'],
      totalEarnings: json['totalEarnings']?.toString(),
      apartment: json['apartment'] ?? '',
      countryCode: json['country_code'] ?? '',
      avatarId: json["avatarId"] ?? (json["avatarData"] != null ? json["avatarData"]["_id"] : null),
      sourceMap: json['source'],
      joinedDate: changeDateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'", json["createdAt"], "dd MMMM, yyyy"),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': userName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'address': address,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'dob': dob,
      'bio': bio,
    };
  }
}
