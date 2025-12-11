import 'package:presshop/features/bank/domain/entities/bank_detail.dart';

class BankDetailModel extends BankDetail {
  const BankDetailModel({
    required super.id,
    required super.bankName,
    required super.bankImage,
    required super.bankLocation,
    required super.currency,
    required super.isDefault,
    required super.accountHolderName,
    required super.sortCode,
    required super.accountNumber,
    required super.stripeBankId,
    required super.availablePayoutMethods,
  });

  factory BankDetailModel.fromJson(Map<String, dynamic> json) {
    return BankDetailModel(
      id: json["bank_detail"] != null ? json['bank_detail']["_id"] ?? "" : "",
      bankName: json["bank_name"] ?? "",
      bankImage: json["bank_info"] != null
          ? json["bank_info"]["logoUrl"] ?? "https://logo.clearbit.com/stripe.com"
          : "https://logo.clearbit.com/stripe.com",
      bankLocation: "Mayfair, London", // Hardcoded in legacy code
      currency: json["currency"] ?? "GBP",
      isDefault: json["is_default"] ?? false,
      accountHolderName: json["bank_detail"] != null
          ? json["bank_detail"]["acc_holder_name"].toString()
          : "",
      sortCode: json["sort_code"] != null ? json["sort_code"].toString() : "",
      accountNumber:
          json["acc_number"] != null ? json['acc_number'].toString() : "",
      stripeBankId: json["bank_detail"] != null
          ? json["bank_detail"]["stripe_bank_id"].toString()
          : "",
      availablePayoutMethods: json["available_payout_methods"] != null
          ? List<String>.from(json["available_payout_methods"])
          : [],
    );
  }
}
