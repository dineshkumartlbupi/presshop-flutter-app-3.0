import 'package:equatable/equatable.dart';

class BankDetail extends Equatable {
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
}
