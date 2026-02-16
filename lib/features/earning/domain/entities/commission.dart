import 'package:equatable/equatable.dart';

class Commission extends Equatable {
  const Commission({
    required this.totalEarning,
    required this.commission,
    required this.commissionReceived,
    required this.commissionPending,
    this.paidOn,
    required this.firstName,
    required this.lastName,
    required this.dateOfJoining,
    required this.avatar,
    this.currency = "",
    this.currencySymbol = "",
  });
  final double totalEarning;
  final double commission;
  final double commissionReceived;
  final double commissionPending;
  final String? paidOn;
  final String firstName;
  final String lastName;
  final String dateOfJoining;
  final String avatar;
  final String currency;
  final String currencySymbol;

  @override
  List<Object?> get props => [
        totalEarning,
        commission,
        commissionReceived,
        commissionPending,
        paidOn,
        firstName,
        lastName,
        dateOfJoining,
        avatar,
        currency,
        currencySymbol,
      ];

  Commission copyWith({
    double? totalEarning,
    double? commission,
    double? commissionReceived,
    double? commissionPending,
    String? paidOn,
    String? firstName,
    String? lastName,
    String? dateOfJoining,
    String? avatar,
    String? currency,
    String? currencySymbol,
  }) {
    return Commission(
      totalEarning: totalEarning ?? this.totalEarning,
      commission: commission ?? this.commission,
      commissionReceived: commissionReceived ?? this.commissionReceived,
      commissionPending: commissionPending ?? this.commissionPending,
      paidOn: paidOn ?? this.paidOn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      avatar: avatar ?? this.avatar,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarning': totalEarning,
      'commission': commission,
      'commissionReceived': commissionReceived,
      'commissionPending': commissionPending,
      'paidOn': paidOn,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfJoining': dateOfJoining,
      'avatar': avatar,
      'currency': currency,
      'currencySymbol': currencySymbol,
    };
  }
}
