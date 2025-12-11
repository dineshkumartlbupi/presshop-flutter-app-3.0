import 'package:equatable/equatable.dart';

class ProfileData extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final String email;
  final String phone;
  final String? profileImage;
  final String? address;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? latitude;
  final String? longitude;
  final String? dob;
  final String? bio;
  final String? currencySymbol;
  final String? totalEarnings;
  final String? apartment;
  final String? countryCode;
  final String? avatarId;
  final Map<String, dynamic>? sourceMap;
  final String? joinedDate;

  const ProfileData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.phone,
    this.profileImage,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.dob,
    this.bio,
    this.currencySymbol,
    this.totalEarnings,
    this.apartment,
    this.countryCode,
    this.avatarId,
    this.sourceMap,
    this.joinedDate,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        userName,
        email,
        phone,
        profileImage,
        address,
        city,
        country,
        postalCode,
        latitude,
        longitude,
        dob,
        bio,
        currencySymbol,
        totalEarnings,
        apartment,
        countryCode,
        avatarId,
        sourceMap,
        joinedDate,
      ];
}
