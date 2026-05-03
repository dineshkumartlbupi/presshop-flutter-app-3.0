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
    required this.stripeStatus,
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
  final StripeStatus stripeStatus;

  ProfileData copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? userName,
    String? role,
    String? status,
    String? hopperStatus,
    String? chatStatus,
    String? profileImage,
    String? avatar,
    bool? isVerified,
    bool? isOnboard,
    bool? isDeleted,
    double? latitude,
    double? longitude,
    int? totalEarnings,
    int? totalHopperArmy,
    Location? location,
    PreferredCurrencySign? preferredCurrencySign,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    StripeStatus? stripeStatus,
  }) {
    return ProfileData(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      status: status ?? this.status,
      hopperStatus: hopperStatus ?? this.hopperStatus,
      chatStatus: chatStatus ?? this.chatStatus,
      profileImage: profileImage ?? this.profileImage,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isOnboard: isOnboard ?? this.isOnboard,
      isDeleted: isDeleted ?? this.isDeleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalHopperArmy: totalHopperArmy ?? this.totalHopperArmy,
      location: location ?? this.location,
      preferredCurrencySign:
          preferredCurrencySign ?? this.preferredCurrencySign,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      stripeStatus: stripeStatus ?? this.stripeStatus,
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

class Location extends Equatable {
  const Location({
    required this.type,
    required this.coordinates,
  });
  final String type;
  final List<double> coordinates;

  Location copyWith({
    String? type,
    List<double>? coordinates,
  }) {
    return Location(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
    );
  }

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

  PreferredCurrencySign copyWith({
    String? symbol,
    String? code,
    String? name,
    String? countryName,
    String? countryCode,
    String? dialCode,
  }) {
    return PreferredCurrencySign(
      symbol: symbol ?? this.symbol,
      code: code ?? this.code,
      name: name ?? this.name,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
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

class StripeStatus extends Equatable {
  const StripeStatus({
    required this.stripeStatusActive,
    required this.stripeStatusReason,
  });
  final String stripeStatusActive;
  final String stripeStatusReason;

  StripeStatus copyWith({
    String? stripeStatusActive,
    String? stripeStatusReason,
  }) {
    return StripeStatus(
      stripeStatusActive: stripeStatusActive ?? this.stripeStatusActive,
      stripeStatusReason: stripeStatusReason ?? this.stripeStatusReason,
    );
  }

  @override
  List<Object?> get props => [stripeStatusActive, stripeStatusReason];
}
