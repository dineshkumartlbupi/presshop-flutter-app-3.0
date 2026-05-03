import 'package:equatable/equatable.dart';

class BankDetail extends Equatable {
  const BankDetail({
    required this.id,
    required this.bankName,
    required this.bankImage,
    required this.bankLocation,
    required this.currency,
    required this.isDefault,
    required this.accountHolderName,
    required this.sortCode,
    required this.accountNumber,
    required this.stripeBankId,
    required this.availablePayoutMethods,
  });
  final String id;
  final String bankName;
  final String bankImage;
  final String bankLocation;
  final String currency;
  final bool isDefault;
  final String accountHolderName;
  final String sortCode;
  final String accountNumber;
  final String stripeBankId;
  final List<String> availablePayoutMethods;

  @override
  List<Object?> get props => [
        id,
        bankName,
        bankImage,
        bankLocation,
        currency,
        isDefault,
        accountHolderName,
        sortCode,
        accountNumber,
        stripeBankId,
        availablePayoutMethods,
      ];

  BankDetail copyWith({
    String? id,
    String? bankName,
    String? bankImage,
    String? bankLocation,
    String? currency,
    bool? isDefault,
    String? accountHolderName,
    String? sortCode,
    String? accountNumber,
    String? stripeBankId,
    List<String>? availablePayoutMethods,
  }) {
    return BankDetail(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      bankImage: bankImage ?? this.bankImage,
      bankLocation: bankLocation ?? this.bankLocation,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      sortCode: sortCode ?? this.sortCode,
      accountNumber: accountNumber ?? this.accountNumber,
      stripeBankId: stripeBankId ?? this.stripeBankId,
      availablePayoutMethods:
          availablePayoutMethods ?? this.availablePayoutMethods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'bank_image': bankImage,
      'bank_location': bankLocation,
      'currency': currency,
      'is_default': isDefault,
      'account_holder_name': accountHolderName,
      'sort_code': sortCode,
      'account_number': accountNumber,
      'stripe_bank_id': stripeBankId,
      'supported_payout_methods': availablePayoutMethods,
    };
  }
}
