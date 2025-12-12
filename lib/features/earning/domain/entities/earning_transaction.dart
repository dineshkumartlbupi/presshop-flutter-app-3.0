import 'package:equatable/equatable.dart';

class EarningTransaction extends Equatable {
  final String id;
  final String amount;
  final String totalEarningAmt; // original_ask_price or hopper_price
  final String status; // paid_status string e.g "Paid"
  final bool paidStatus; // boolean check
  final String contentTitle;
  final String contentType;
  final String createdAt; // camelCase
  final String createdAT; // compatibility alias if needed, but better to use createdAt in new code. 
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

  final String contentId; // Added for TransactionDetailScreen usage (line 118: widget.transactionData!.contentId)

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
  }) : createdAT = createdAt;

  @override
  List<Object?> get props => [
    id, amount, totalEarningAmt, status, paidStatus, contentTitle, contentType, createdAt, dueDate, adminFullName,
    payableT0Hopper, payableCommission, stripefee, hopperBankLogo, hopperBankName, userFirstName, userLastName,
    contentDataList, type, typesOfContent, hopperAvatar, uploadContent, contentId
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
