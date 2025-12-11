import 'package:equatable/equatable.dart';

class EarningTransaction extends Equatable {
  final String id;
  final String amount;
  final String totalEarningAmt; // original_ask_price or hopper_price
  final String status; // paid_status
  final bool isPaid;
  final String contentTitle;
  final String contentType;
  final String createdAt;
  final String adminFullName; // media_house name
  final String companyLogo;
  final String contentImage;
  
  // Add other necessary fields mapping to UI requirements
  // Keeping it minimal for now based on common usage, but can be expanded.
  
  final String payableT0Hopper;
  final String payableCommission;
  final String stripefee;
  final String hopperBankLogo;
  final String hopperBankName;
  final String userFirstName;
  final String userLastName;
  
  // Note: For contentDataList, strictly we should use Entity.
  // But for now keeping dynamic or list of models if imported? 
  // No, let's use List<dynamic> or skip detailed content mapping if not strictly needed or map to simple Content structure.
  // Actually TransactionDetailScreen uses it.
  final List<dynamic> contentDataList; // Should be List<ContentData>
  final String type;
  final bool typesOfContent;
  final String hopperAvatar;

  const EarningTransaction({
    required this.id,
    required this.amount,
    required this.totalEarningAmt,
    required this.status,
    required this.isPaid,
    required this.contentTitle,
    required this.contentType,
    required this.createdAt,
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
  });

  @override
  List<Object?> get props => [
    id, amount, totalEarningAmt, status, isPaid, contentTitle, contentType, createdAt, adminFullName,
    payableT0Hopper, payableCommission, stripefee, hopperBankLogo, hopperBankName, userFirstName, userLastName,
    contentDataList, type, typesOfContent, hopperAvatar
  ];
}

class TransactionsResult extends Equatable {
  final List<EarningTransaction> transactions;
  final String totalEarning;

  const TransactionsResult({
    required this.transactions,
    required this.totalEarning,
  });

  @override
  List<Object?> get props => [transactions, totalEarning];
}
