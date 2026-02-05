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
}
