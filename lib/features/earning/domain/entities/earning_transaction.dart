import 'package:equatable/equatable.dart';

class EarningTransaction extends Equatable {
  // Added for TransactionDetailScreen usage (line 118: widget.transactionData!.contentId)

  const EarningTransaction({
    required this.id,
    required this.amount,
    required this.totalEarningAmt,
    required this.status,
    required this.paidStatus,
    required this.contentTitle,
    required this.contentType,
    required this.createdAt,
    required this.dueDate,
    required this.adminFullName,
    required this.companyLogo,
    required this.contentImage,
    required this.payableT0Hopper,
    required this.payableCommission,
    required this.stripefee,
    required this.hopperBankLogo,
    required this.hopperBankName,
    required this.userFirstName,
    required this.userLastName,
    required this.contentDataList,
    required this.type,
    required this.typesOfContent,
    this.hopperAvatar = "",
    this.uploadContent = "",
    this.contentId = "",
    this.currency = "",
    this.currencySymbol = "",
  }) : createdAT = createdAt;
  final String id;
  final String amount;
  final String totalEarningAmt; // original_ask_price or hopper_price
  final String status; // paid_status string e.g "Paid"
  final bool paidStatus; // boolean check
  final String contentTitle;
  final String contentType;
  final String createdAt; // camelCase
  final String
      createdAT; // compatibility alias if needed, but better to use createdAt in new code.
  // However, I'll alias it via getter or just stick to one.
  // Analysis error said `createdAT` not defined.
  // I will add `createdAT` getter for compatibility.

  final String dueDate; // Added

  final String adminFullName; // media_house name
  final String companyLogo;
  final String contentImage;

  final String payableT0Hopper;
  final String payableCommission;
  final String stripefee;
  final String hopperBankLogo;
  final String hopperBankName;
  final String userFirstName;
  final String userLastName;

  final List<dynamic> contentDataList;
  final String type;
  final bool typesOfContent;
  final String hopperAvatar;
  final String uploadContent;

  final String contentId;
  final String currency;
  final String currencySymbol;

  @override
  List<Object?> get props => [
        id,
        amount,
        totalEarningAmt,
        status,
        paidStatus,
        contentTitle,
        contentType,
        createdAt,
        dueDate,
        adminFullName,
        payableT0Hopper,
        payableCommission,
        stripefee,
        hopperBankLogo,
        hopperBankName,
        userFirstName,
        userLastName,
        contentDataList,
        type,
        typesOfContent,
        hopperAvatar,
        uploadContent,
        contentId,
        currency,
        currencySymbol
      ];

  EarningTransaction copyWith({
    String? id,
    String? amount,
    String? totalEarningAmt,
    String? status,
    bool? paidStatus,
    String? contentTitle,
    String? contentType,
    String? createdAt,
    String? dueDate,
    String? adminFullName,
    String? companyLogo,
    String? contentImage,
    String? payableT0Hopper,
    String? payableCommission,
    String? stripefee,
    String? hopperBankLogo,
    String? hopperBankName,
    String? userFirstName,
    String? userLastName,
    List<dynamic>? contentDataList,
    String? type,
    bool? typesOfContent,
    String? hopperAvatar,
    String? uploadContent,
    String? contentId,
    String? currency,
    String? currencySymbol,
  }) {
    return EarningTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      totalEarningAmt: totalEarningAmt ?? this.totalEarningAmt,
      status: status ?? this.status,
      paidStatus: paidStatus ?? this.paidStatus,
      contentTitle: contentTitle ?? this.contentTitle,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      adminFullName: adminFullName ?? this.adminFullName,
      companyLogo: companyLogo ?? this.companyLogo,
      contentImage: contentImage ?? this.contentImage,
      payableT0Hopper: payableT0Hopper ?? this.payableT0Hopper,
      payableCommission: payableCommission ?? this.payableCommission,
      stripefee: stripefee ?? this.stripefee,
      hopperBankLogo: hopperBankLogo ?? this.hopperBankLogo,
      hopperBankName: hopperBankName ?? this.hopperBankName,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      contentDataList: contentDataList ?? this.contentDataList,
      type: type ?? this.type,
      typesOfContent: typesOfContent ?? this.typesOfContent,
      hopperAvatar: hopperAvatar ?? this.hopperAvatar,
      uploadContent: uploadContent ?? this.uploadContent,
      contentId: contentId ?? this.contentId,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'totalEarningAmt': totalEarningAmt,
      'status': status,
      'paidStatus': paidStatus,
      'contentTitle': contentTitle,
      'contentType': contentType,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'adminFullName': adminFullName,
      'companyLogo': companyLogo,
      'contentImage': contentImage,
      'payableT0Hopper': payableT0Hopper,
      'payableCommission': payableCommission,
      'stripefee': stripefee,
      'hopperBankLogo': hopperBankLogo,
      'hopperBankName': hopperBankName,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'contentDataList': contentDataList,
      'type': type,
      'typesOfContent': typesOfContent,
      'hopperAvatar': hopperAvatar,
      'uploadContent': uploadContent,
      'contentId': contentId,
      'currency': currency,
      'currencySymbol': currencySymbol,
    };
  }
}

class TransactionsResult extends Equatable {
  const TransactionsResult({
    required this.transactions,
    required this.totalEarning,
  });
  final List<EarningTransaction> transactions;
  final String totalEarning;

  @override
  List<Object?> get props => [transactions, totalEarning];
}
