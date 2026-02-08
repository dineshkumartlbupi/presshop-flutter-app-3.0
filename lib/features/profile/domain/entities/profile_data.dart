import 'package:equatable/equatable.dart';

class ProfileData extends Equatable {
  const ProfileData({
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
  });
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
  final int totalEarnings;
  final int totalHopperArmy;
  final Location location;
  final PreferredCurrencySign preferredCurrencySign;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

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
      ];
}

class Location extends Equatable {
  const Location({
    required this.type,
    required this.coordinates,
  });
  final String type;
  final List<double> coordinates;

  @override
  List<Object?> get props => [type, coordinates];
}

class PreferredCurrencySign extends Equatable {
  const PreferredCurrencySign({
    required this.symbol,
    required this.code,
    required this.name,
    required this.countryName,
    required this.countryCode,
    required this.dialCode,
  });
  final String symbol;
  final String code;
  final String name;
  final String countryName;
  final String countryCode;
  final String dialCode;

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
