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
    String id = "";
    if (json["bank_detail"] != null && json["bank_detail"] is Map) {
      id = (json["bank_detail"]["_id"] ?? "").toString();
    } else if (json["_id"] != null) {
      id = json["_id"].toString();
    } else if (json["id"] != null) {
      id = json["id"].toString();
    }

    if (id.isEmpty) {
      id = (json["stripe_bank_id"] ?? "").toString();
    }

    String bankImage = "https://logo.clearbit.com/stripe.com";
    if (json["bank_info"] != null && json["bank_info"] is Map) {
      bankImage = (json["bank_info"]["logoUrl"] ?? bankImage).toString();
    } else if (json["bank_image"] != null) {
      bankImage = json["bank_image"].toString();
    }

    String accountHolderName = "";
    if (json["bank_detail"] != null && json["bank_detail"] is Map) {
      accountHolderName =
          (json["bank_detail"]["acc_holder_name"] ?? "").toString();
    } else if (json["account_holder_name"] != null) {
      accountHolderName = json["account_holder_name"].toString();
    }

    String stripeBankId = (json["stripe_bank_id"] ?? "").toString();
    if (stripeBankId.isEmpty &&
        json["bank_detail"] != null &&
        json["bank_detail"] is Map) {
      stripeBankId = (json["bank_detail"]["stripe_bank_id"] ?? "").toString();
    }

    return BankDetailModel(
      id: id,
      bankName: (json["bank_name"] ?? "").toString(),
      bankImage: bankImage,
      bankLocation: (json["bank_location"] ?? "Mayfair, London").toString(),
      currency: (json["currency"] ?? "GBP").toString(),
      isDefault: json["is_default"] == true || json["is_default"] == "true",
      accountHolderName: accountHolderName,
      sortCode: (json["sort_code"] ?? "").toString(),
      accountNumber:
          (json["acc_number"] ?? json["account_number"] ?? "").toString(),
      stripeBankId: stripeBankId,
      availablePayoutMethods: json["available_payout_methods"] != null
          ? List<String>.from(json["available_payout_methods"])
          : (json["supported_payout_methods"] != null
              ? List<String>.from(json["supported_payout_methods"])
              : []),
    );
  }

  @override
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
