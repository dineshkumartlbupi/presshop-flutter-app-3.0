import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? token;
  final String? referralCode;
  final String? currencySymbol;
  final String? totalHopperArmy;
  final String? avatarId;
  final String? avatar;
  final String? userName;
  final String? phone;
  final String? countryCode;
  final String? address;
  final String? latitude;
  final String? longitude;
  final bool? receiveTaskNotification;
  final bool? isTermAccepted;
  final String? profileImage;
  final String? refreshToken;
  final Map<String, dynamic>? source;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.token,
    this.referralCode,
    this.currencySymbol,
    this.totalHopperArmy,
    this.avatarId,
    this.avatar,
    this.userName,
    this.phone,
    this.countryCode,
    this.address,
    this.latitude,
    this.longitude,
    this.receiveTaskNotification,
    this.isTermAccepted,
    this.profileImage,
    this.refreshToken,
    this.source,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        token,
        referralCode,
        currencySymbol,
        totalHopperArmy,
        avatarId,
        avatar,
        userName,
        phone,
        countryCode,
        address,
        latitude,
        longitude,
        receiveTaskNotification,
        isTermAccepted,
        profileImage,
        refreshToken,
        source
      ];
}
