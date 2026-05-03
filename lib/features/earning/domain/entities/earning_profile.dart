import 'package:equatable/equatable.dart';

class EarningProfile extends Equatable {
  const EarningProfile({
    required this.id,
    required this.avatar,
    required this.totalEarning,
    this.currency = "",
    this.currencySymbol = "",
  });
  final String id;
  final String avatar;
  final String totalEarning;
  final String currency;
  final String currencySymbol;

  @override
  List<Object?> get props =>
      [id, avatar, totalEarning, currency, currencySymbol];

  EarningProfile copyWith({
    String? id,
    String? avatar,
    String? totalEarning,
    String? currency,
    String? currencySymbol,
  }) {
    return EarningProfile(
      id: id ?? this.id,
      avatar: avatar ?? this.avatar,
      totalEarning: totalEarning ?? this.totalEarning,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar': avatar,
      'total_earning': totalEarning,
      'currency': currency,
      'currency_symbol': currencySymbol,
    };
  }
}
