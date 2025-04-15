import 'package:flutter/cupertino.dart';
import 'package:presshop/utils/Common.dart';

import '../menuScreen/feedScreen/feedDataModel.dart';

class EarningProfileDataModel {
  String id = '';
  String category = '';
  bool isSocialRegister = false;
  String role = '';
  String status = '';
  String hopperUserFirstName = '';
  String hopperUserLastName = '';
  String hopperUserEmail = '';
  String avatarId = '';
  String avatar = '';
  String totalEarning = "";

  EarningProfileDataModel({
    required this.id,
    required this.category,
    required this.isSocialRegister,
    required this.role,
    required this.status,
    required this.hopperUserFirstName,
    required this.hopperUserLastName,
    required this.hopperUserEmail,
    required this.avatarId,
    required this.avatar,
    required this.totalEarning,
  });

  factory EarningProfileDataModel.fromJson(Map<String, dynamic> json) {
    return EarningProfileDataModel(
      id: json['_id'] ?? '',
      category: json['hopper_id'] != null ? json['hopper_id']['category'] : '',
      isSocialRegister: json['hopper_id'] != null ? json['hopper_id']['isSocialRegister'] : false,
      role: json['hopper_id'] != null ? json['hopper_id']['status'] : '',
      status: json['hopper_id'] != null ? json['hopper_id']['_id'] : '',
      hopperUserFirstName: json['hopper_id'] != null ? json['hopper_id']['first_name'] : '',
      hopperUserLastName: json['hopper_id'] != null ? json['hopper_id']['last_name'] : '',
      hopperUserEmail: json['hopper_id'] != null ? json['hopper_id']['email'] : '',
      avatarId: json['avatar_details'] != null ? json['avatar_details']['_id'] : '',
      avatar: json['avatar_details'] != null ? json['avatar_details']['avatar'] : '',
      totalEarning: json['total_earining'].toString() ?? '',
    );
  }
}

class EarningTransactionDetail {
  String id = '';
  bool paidStatus = false;
  String adminFullName = "";
  String adminProfileImage = "";
  String adminCountryCode = "";
  int adminPhoneNumber = 0;
  String adminEmail = "";
  String adminAccountName = "";
  String adminBankName = "";
  String adminSortCode = "";
  String adminAccountNumber = "";
  String adminUserName = "";
  String adminRole = "";
  String adminStatus = "";
  String saleStatus = "";
  String stripefee = "";
  String contentType = "";
  List<ContentDataModel> contentDataList = [];
  List<BankDataModel> userBankDetailList = [];
  String userFirstName = "";
  String userLastName = "";
  String userEmail = "";
  int userPhone = 0;
  String userAddress = "";
  String vat = '';
  String amount = '';
  String allAmount = "";
  String totalEarningAmt = "";
  String payableT0Hopper = '';
  String payableCommission = '';
  String type = '';
  String percentage = '';
  bool typesOfContent = false;
  String createdAT = '';
  String dueDate = '';
  String updatedAT = '';
  String contentId = "";
  String hopperAvatar = "";
  String hopperBankName = "";
  String hopperBankLogo = "";

  String mediaHouseCompanyImage = "";
  String mediaHouseCompanyName = "";
  String contentTitle = "";
  String companyLogo = "";
  String contentImage = "";

  EarningTransactionDetail(
      {required this.id,
      required this.paidStatus,
      required this.adminFullName,
      required this.adminProfileImage,
      required this.adminCountryCode,
      required this.adminPhoneNumber,
      required this.adminEmail,
      required this.adminAccountName,
      required this.adminBankName,
      required this.adminSortCode,
      required this.adminAccountNumber,
      required this.adminUserName,
      required this.adminRole,
      required this.adminStatus,
      required this.saleStatus,
      required this.stripefee,
      required this.contentType,
      required this.contentDataList,
      required this.userBankDetailList,
      required this.userFirstName,
      required this.userLastName,
      required this.userEmail,
      required this.userPhone,
      required this.userAddress,
      required this.vat,
      required this.contentTitle,
      required this.amount,
      required this.allAmount,
      required this.totalEarningAmt,
      required this.payableT0Hopper,
      required this.payableCommission,
      required this.type,
      required this.percentage,
      required this.typesOfContent,
      required this.createdAT,
      required this.dueDate,
      required this.updatedAT,
      required this.companyLogo,
      required this.contentId,
      this.hopperAvatar = "",
      this.hopperBankName = "",
      this.hopperBankLogo = "",
      this.contentImage = ""});

  factory EarningTransactionDetail.fromJson(Map<String, dynamic> json) {
    List<BankDataModel> bankData = [];
    List<ContentDataModel> contentData = [];
    dynamic vatFee;
    dynamic totalAmount;
    dynamic amount;
    if (json['hopper_id'] != null) {
      if (json['hopper_id']['bank_detail'] != null) {
        var data = json['hopper_id']['bank_detail'] as List;
        bankData = data.map((e) => BankDataModel.fromJson(e)).toList();
      }
    }
    if (json['content_id'] != null) {
      if (json['content_id']['content'] != null) {
        var data = json['content_id']['content'] as List;
        contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
      }
    }
    if (json['Vat'] != null && json['amount'] != null) {
      vatFee = json['Vat'];
      totalAmount = json['amount'];
      amount = totalAmount - vatFee;
    }

    var contentsImage = "";
   try{
     if (json["content_id"] is Map<String, dynamic>) {
       var content = (json["content_id"] as Map<String, dynamic>)["content"];
       if (content is List) {
         // debugPrint("ImageContent: $content");
         var images = content.where((media) => media is Map<String, dynamic> && media["media_type"] != null).toList();
         if (images.isNotEmpty) {
           contentsImage = images.first["watermark"].toString();
         }
       }
     }
   }catch(ex){
     print(ex);
   }
    debugPrint("BankLogo: ${json["received_bank_detail"] != null ? json["received_bank_detail"]["bank_logo"] ?? "" : ""}");
    return EarningTransactionDetail(
        id: json['_id'] ?? '',
        totalEarningAmt: json['original_ask_price'].toString(),
        paidStatus: json['paid_status_for_hopper'] ?? false,
        adminFullName: json['media_house_id'] != null ? json['media_house_id']['full_name'].toString() : '',
        adminProfileImage: (json['media_house_id'] != null && json['media_house_id']['admin_detail'] != null) ? json['media_house_id']['admin_detail']['admin_profile'].toString() : '',
        adminCountryCode: json['media_house_id'] != null ? json['media_house_id']['country_code'].toString() : '',
        adminPhoneNumber: json['media_house_id'] != null ? json['media_house_id']['phone'] : 0,
        adminEmail: json['media_house_id'] != null ? json['media_house_id']['email'].toString() : '',
        adminAccountName: (json['media_house_id'] != null && json['media_house_id']['company_bank_details'] != null) ? json['media_house_id']['company_bank_details']['company_account_name'].toString() : '',
        adminBankName: (json['media_house_id'] != null && json['media_house_id']['company_bank_details'] != null) ? json['media_house_id']['company_bank_details']['bank_name'].toString() : '',
        adminSortCode: (json['media_house_id'] != null && json['media_house_id']['company_bank_details'] != null) ? json['media_house_id']['company_bank_details']['sort_code'].toString() : '',
        adminAccountNumber: (json['media_house_id'] != null && json['media_house_id']['company_bank_details'] != null) ? json['media_house_id']['company_bank_details']['account_number'].toString() : '',
        companyLogo: json['media_house_id'] != null ? json['media_house_id']['profile_image'].toString() : '',
        adminRole: json['media_house_id'] != null ? json['media_house_id']['role'].toString() : '',
        adminStatus: json['media_house_id'] != null ? json['media_house_id']['status'].toString() : '',
        contentType: json['content_id'] != null ? json['content_id']['type'] : '',
        saleStatus: json['content_id'] != null ? json['content_id']['sale_status'] : '',
        contentDataList: contentData,
        userBankDetailList: bankData,
        userFirstName: json['hopper_id'] != null ? json['hopper_id']['first_name'] : '',
        userLastName: json['hopper_id'] != null ? json['hopper_id']['last_name'] : '',
        userEmail: json['hopper_id'] != null ? json['hopper_id']['email'] : '',
        userPhone: json['hopper_id'] != null ? json['hopper_id']['phone'] : 0,
        userAddress: json['hopper_id'] != null ? json['hopper_id']['address'] : '',
        hopperAvatar: json['hopper_id'] != null ? json['hopper_id']['avatar'] ?? "" : '',
        hopperBankName: json["received_bank_detail"] != null ? json["received_bank_detail"]["bank_name"] ?? "" : "",
        hopperBankLogo: json["received_bank_detail"] != null ? json["received_bank_detail"]["bank_logo"] ?? "" : "",
        vat: vatFee.toString(),
        allAmount: totalAmount.toString(),
        payableT0Hopper: json['payable_to_hopper'] != "null" ? json['payable_to_hopper'].toString() : '',
        payableCommission: json['presshop_commission'].toString() ?? '',
        stripefee: json.containsKey("stripe_fee") ? json["stripe_fee"].toString() : "0.0",
        type: json['type'] ?? '',
        percentage: json.containsKey("percentage") ? json["percentage"].toString() : "0.0",
        typesOfContent: json['typeofcontent'] == "shared" ? false : true,
        createdAT: dateTimeFormatter(dateTime: json['createdAt']),
        updatedAT: dateTimeFormatter(dateTime: json['updatedAt']),
        dueDate: json['Due_date'] ?? "",
        contentId: json['content_id'] != null ? json['content_id']['_id'] : '',
        amount: amount.toString(),
        contentTitle: json['content_id'] != null ? json['content_id']['heading'] : '',
        contentImage: contentsImage,
        adminUserName: '');
  }

  factory EarningTransactionDetail.taskFromJson(Map<String, dynamic> json) {
    return EarningTransactionDetail(
      contentTitle:"",
      id: json['_id'] ?? "",
      paidStatus: json['paid_status_for_hopper'] ?? false,
      adminFullName: "",
      adminProfileImage: "",
      adminCountryCode: "",
      adminPhoneNumber: 0,
      adminEmail: "",
      adminAccountName: "",
      adminBankName: "",
      adminSortCode: "",
      adminAccountNumber: "",
      adminUserName: "",
      adminRole: "",
      adminStatus: "",
      saleStatus: "",
      stripefee: json['stripe_fee']?.toString() ?? "0.0",
      contentType: json['type'] ?? "",
      contentDataList: (json['purchased_task_content'] as List<dynamic>?)
          ?.map((e) => ContentDataModel.fromJson(e))
          .toList() ??
          [],
      userBankDetailList: (json['hopper_id']['bank_detail'] as List<dynamic>?)
          ?.map((e) => BankDataModel.fromJson(e))
          .toList() ??
          [],
      userFirstName: json['hopper_id']['first_name'] ?? "",
      userLastName: json['hopper_id']['last_name'] ?? "",
      userEmail: json['hopper_id']['email'] ?? "",
      userPhone: json['hopper_id']['phone'] ?? 0,
      userAddress: json['hopper_id']['address'] ?? "",
      vat: json['Vat']?.toString() ?? "0.0",
      amount: json['amount']?.toString() ?? "0.0",
      allAmount: json['total_received_from_stripe']?.toString() ?? "0.0",
      totalEarningAmt: json['hopper_price']?.toString() ?? "0.0",
      payableT0Hopper: json['payable_to_hopper']?.toString() ?? "0.0",
      payableCommission: json['presshop_commission']?.toString() ?? "0.0",
      type: json['type'] ?? "",
      percentage: json['presshop_commission']?.toString() ?? "0.0",
      typesOfContent: false,
      createdAT:dateTimeFormatter(dateTime:  json['createdAt'] ?? ""),
      dueDate: dateTimeFormatter(dateTime: json['Due_date'] ?? ""),
      updatedAT: dateTimeFormatter(dateTime:json['updatedAt'] ?? ""),
      companyLogo: json['received_bank_detail']['bank_logo'] ?? "",
      contentId: json['task_id'] ?? "",
      hopperAvatar: json['hopper_id']['avatar'] ?? "",
      hopperBankName: json['received_bank_detail']['bank_name'] ?? "",
      hopperBankLogo: json['received_bank_detail']['bank_logo'] ?? "",
      contentImage: json['purchased_task_content'] != null &&
          json['purchased_task_content'].isNotEmpty
          ? json['purchased_task_content'][0]['videothubnail'] ?? ""
          : "",
    );
  }
}

class BankDataModel {
  bool isDefault = false;
  String id = '';
  String accountHolderName = '';
  String bankName = '';
  String sortCode = '';
  int accountNumber = 0;

  BankDataModel({
    required this.isDefault,
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.sortCode,
    required this.accountNumber,
  });

  factory BankDataModel.fromJson(Map<String, dynamic> json) {
    return BankDataModel(isDefault: json['is_default'] ?? false, id: json['_id'] ?? '', accountHolderName: json['acc_holder_name'] ?? '', bankName: json['bank_name'] ?? '', sortCode: json['sort_code'] ?? '', accountNumber: json['acc_number'] ?? 0);
  }
}
