import 'package:flutter/cupertino.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/feed/presentation/pages/feed_data_model.dart';
import '../../domain/entities/earning_transaction.dart';

class EarningProfileDataModel {
  EarningProfileDataModel({
    required this.id,
    required this.avatarId,
    required this.avatar,
    required this.totalEarning,
    required this.currency,
    required this.currencySymbol,
  });

  factory EarningProfileDataModel.fromJson(Map<String, dynamic> json) {
    var data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    // Check for nested data object if total_earnings is missing at first level
    if (data['data'] is Map<String, dynamic> &&
        !data.containsKey('total_earnings') &&
        !data.containsKey('totalEarnings')) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData.containsKey('total_earnings') ||
          innerData.containsKey('totalEarnings')) {
        data = innerData;
      }
    }

    return EarningProfileDataModel(
      id: data['_id']?.toString() ?? data['user_id']?.toString() ?? '',
      avatarId: data['avatar_details'] != null
          ? data['avatar_details']['_id']?.toString() ?? ''
          : '',
      avatar: data['avatar_details'] != null
          ? data['avatar_details']['avatar']?.toString() ?? ''
          : '',
      totalEarning: double.tryParse(data['total_earnings']?.toString() ??
                  data['totalEarnings']?.toString() ??
                  data['total_earning']?.toString() ??
                  data['totalEarning']?.toString() ??
                  "")
              ?.toString() ??
          "0",
      currency: data['currency']?.toString() ?? '',
      currencySymbol: data['currency_symbol']?.toString() ??
          data['currencySymbol']?.toString() ??
          '',
    );
  }
  String id = '';
  String avatarId = '';
  String avatar = '';
  String totalEarning = "";
  String currency = "";
  String currencySymbol = "";
}

class CommissionData {
  factory CommissionData.fromJson(Map<String, dynamic> json) {
    double parseDouble(String key1, [String? key2, String? key3]) {
      return double.tryParse(json[key1]?.toString() ??
              (key2 != null ? json[key2]?.toString() : null) ??
              (key3 != null ? json[key3]?.toString() : null) ??
              "") ??
          0.0;
    }

    return CommissionData(
      totalEarning:
          parseDouble('totalEarning', 'total_earnings', 'total_earning'),
      commission: parseDouble('commission', 'commission_amount'),
      avatar: (json['avatarInfo'] != null && json['avatarInfo'] is Map)
          ? '${json['avatarInfo']['avatar'] ?? ''}'.trim()
          : '',
      commissionReceived:
          parseDouble('commissionReceived', 'commission_received'),
      commissionPending: parseDouble('commissionPending', 'commission_pending'),
      paidOn: json['paidOn'] != null
          ? dateTimeFormatter(dateTime: json['paidOn'].toString())
          : null,
      firstName: json['first_name'] ??
          json['firstName'] ??
          (json['avatarInfo'] != null
              ? (json['avatarInfo']['name'] ?? '')
              : ''),
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      dateOfJoining: json['dateOfJoining'] != null
          ? dateTimeFormatter(dateTime: json['dateOfJoining'].toString())
          : '',
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] ?? '').toString(),
    );
  }
  CommissionData({
    required this.totalEarning,
    required this.commission,
    required this.commissionReceived,
    required this.commissionPending,
    required this.paidOn,
    required this.firstName,
    required this.lastName,
    required this.dateOfJoining,
    required this.avatar,
    this.currency = "",
    this.currencySymbol = "",
  });

  double totalEarning;
  double commission;
  double commissionReceived;
  double commissionPending;
  String? paidOn;
  String firstName;
  String lastName;
  String dateOfJoining;
  String avatar;
  String currency;
  String currencySymbol;
}

class EarningTransactionDetail {
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
      required this.mediaTypeImage,
      this.hopperAvatar = "",
      this.hopperBankName = "",
      this.hopperBankLogo = "",
      this.contentImage = "",
      this.currency = "",
      this.currencySymbol = ""});

  factory EarningTransactionDetail.fromJson(Map<String, dynamic> json) {
    List<BankDataModel> bankData = [];
    List<ContentDataModel> contentData = [];
    dynamic vatFee;
    dynamic totalAmount;
    dynamic amount;

    final hopper = json['hopper_id'];
    final mediaHouse = json['media_house_id'];
    final content = json['content_id'];

    if (hopper is Map<String, dynamic>) {
      if (hopper['bank_detail'] != null) {
        var data = hopper['bank_detail'] as List;
        bankData = data.map((e) => BankDataModel.fromJson(e)).toList();
      }
    }

    if (json['type'] == 'task_content') {
      if (json['purchased_task_content'] is List) {
        var data = json['purchased_task_content'] as List;
        contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
      }
    } else {
      if (content is Map<String, dynamic>) {
        if (content['content'] != null) {
          var data = content['content'] as List;
          contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
        }
      }
    }

    if (json['Vat'] != null && json['amount'] != null) {
      vatFee = json['Vat'];
      totalAmount = json['amount'];
      amount = totalAmount - vatFee;
    } else {
      amount = json['amount'];
    }

    var contentsImage = "";
    try {
      if (content is Map<String, dynamic>) {
        var contentList = content["content"];
        if (contentList is List) {
          var images = contentList
              .where((media) =>
                  media is Map<String, dynamic> && media["media_type"] != null)
              .toList();
          if (images.isNotEmpty) {
            contentsImage = images.first["watermark"]?.toString() ?? "";
          }
        }
      }
    } catch (ex) {
      print(ex);
    }

    String adminName = "";
    String adminProfile = "";
    String adminPhone = "";
    String adminEmailAddr = "";
    String adminAccName = "";
    String adminBnkName = "";
    String adminSrtCode = "";
    String adminAccNum = "";
    String compLogo = "";

    if (mediaHouse is Map<String, dynamic>) {
      adminName = (mediaHouse['full_name'] ??
              mediaHouse['company_name'] ??
              '${mediaHouse['firstName'] ?? ''} ${mediaHouse['lastName'] ?? ''}')
          .toString()
          .trim();
      adminProfile = (mediaHouse['profile_image'] ??
              mediaHouse['profileImage'] ??
              (mediaHouse['admin_detail'] != null
                  ? mediaHouse['admin_detail']['admin_profile']
                  : ""))
          .toString();
      adminPhone = (mediaHouse['phone'] ?? "").toString();
      adminEmailAddr = (mediaHouse['email'] ?? "").toString();
      compLogo =
          (mediaHouse['profile_image'] ?? mediaHouse['profileImage'] ?? "")
              .toString();

      if (mediaHouse['company_bank_details'] is Map) {
        var bank = mediaHouse['company_bank_details'];
        adminAccName = (bank['company_account_name'] ?? "").toString();
        adminBnkName = (bank['bank_name'] ?? "").toString();
        adminSrtCode = (bank['sort_code'] ?? "").toString();
        adminAccNum = (bank['account_number'] ?? "").toString();
      }
    }

    String uFirstName = "";
    String uLastName = "";
    String uEmail = "";
    String uPhone = "";
    String uAddress = "";
    String hAvatar = "";

    if (hopper is Map<String, dynamic>) {
      uFirstName =
          (hopper['first_name'] ?? hopper['firstName'] ?? "").toString();
      uLastName = (hopper['last_name'] ?? hopper['lastName'] ?? "").toString();
      uEmail = (hopper['email'] ?? "").toString();
      uPhone = (hopper['phone'] ?? "").toString();
      uAddress = (hopper['address'] ?? "").toString();
      hAvatar = (hopper['avatar'] ?? hopper['profileImage'] ?? "").toString();
    }

    String cTitle = "";
    String cType = "";
    String sStatus = "";
    String cId = "";

    if (content is Map<String, dynamic>) {
      cTitle = (content['heading'] ?? content['title'] ?? "").toString();
      cType = (content['type'] ?? "").toString();
      sStatus = (content['sale_status'] ?? "").toString();
      cId = (content['_id'] ?? "").toString();
    } else {
      cId = content?.toString() ?? "";
    }

    return EarningTransactionDetail(
        id: json['_id'] ?? '',
        mediaTypeImage: "",
        totalEarningAmt: json['type'] == 'task_content'
            ? double.tryParse(json['hopper_price']?.toString() ??
                        json['payable_to_hopper']?.toString() ??
                        json['amount']?.toString() ??
                        "")
                    ?.toString() ??
                "0.0"
            : double.tryParse(json['original_ask_price']?.toString() ??
                        json['payable_to_hopper']?.toString() ??
                        json['amount']?.toString() ??
                        "")
                    ?.toString() ??
                "0.0",
        paidStatus: json['paid_status_for_hopper'] ?? false,
        adminFullName: adminName,
        adminProfileImage: adminProfile,
        adminCountryCode: (mediaHouse is Map ? mediaHouse['country_code'] : '')?.toString() ??
            '',
        adminPhoneNumber: adminPhone,
        adminEmail: adminEmailAddr,
        adminAccountName: adminAccName,
        adminBankName: adminBnkName,
        adminSortCode: adminSrtCode,
        adminAccountNumber: adminAccNum,
        companyLogo: compLogo,
        adminRole:
            (mediaHouse is Map ? mediaHouse['role'] : '')?.toString() ?? '',
        adminStatus:
            (mediaHouse is Map ? mediaHouse['status'] : '')?.toString() ?? '',
        contentType: cType,
        saleStatus: sStatus,
        contentDataList: contentData,
        userBankDetailList: bankData,
        userFirstName: uFirstName,
        userLastName: uLastName,
        userEmail: uEmail,
        userPhone: uPhone,
        userAddress: uAddress,
        hopperAvatar: hAvatar,
        hopperBankName: json["received_bank_detail"] != null
            ? json["received_bank_detail"]["bank_name"] ?? ""
            : "",
        hopperBankLogo: json["received_bank_detail"] != null ? json["received_bank_detail"]["bank_logo"] ?? "" : "",
        vat: double.tryParse(vatFee?.toString() ?? "")?.toString() ?? "0.0",
        allAmount: double.tryParse(totalAmount?.toString() ?? "")?.toString() ?? "0.0",
        payableT0Hopper: double.tryParse(json['payable_to_hopper']?.toString() ?? "")?.toString() ?? "0.0",
        payableCommission: double.tryParse(json['presshop_commission']?.toString() ?? "")?.toString() ?? "0.0",
        stripefee: double.tryParse(json['stripe_fee']?.toString() ?? "")?.toString() ?? "0.0",
        type: json['type'] ?? '',
        percentage: double.tryParse(json['percentage']?.toString() ?? "")?.toString() ?? "0.0",
        typesOfContent: json['typeofcontent'] == "shared" ? false : true,
        createdAT: dateTimeFormatter(dateTime: json['createdAt']),
        updatedAT: dateTimeFormatter(dateTime: json['updatedAt']),
        dueDate: json['Due_date'] ?? "",
        contentId: cId,
        amount: double.tryParse(amount?.toString() ?? "")?.toString() ?? "0.0",
        contentTitle: cTitle,
        contentImage: contentsImage,
        currency: (json['currency'] ?? '').toString(),
        currencySymbol: (json['currency_symbol'] != null && json['currency_symbol'].toString().isNotEmpty) ? json['currency_symbol'].toString() : getCurrencySymbol(json['currency']?.toString()),
        adminUserName: '');
  }

  factory EarningTransactionDetail.taskFromJson(Map<String, dynamic> json) {
    final hopper = json['hopper_id'];
    final bankDetail = json['received_bank_detail'];

    return EarningTransactionDetail(
      contentTitle: "",
      id: json['_id'] ?? "",
      mediaTypeImage: "",
      paidStatus: json['paid_status_for_hopper'] ?? false,
      adminFullName: "",
      adminProfileImage: "",
      adminCountryCode: "",
      adminPhoneNumber: "0",
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
      userBankDetailList: (hopper is Map && hopper['bank_detail'] != null)
          ? (hopper['bank_detail'] as List<dynamic>?)
                  ?.map((e) => BankDataModel.fromJson(e))
                  .toList() ??
              []
          : [],
      userFirstName:
          (hopper is Map ? hopper['first_name'] ?? hopper['firstName'] : "")
                  ?.toString() ??
              "",
      userLastName:
          (hopper is Map ? hopper['last_name'] ?? hopper['lastName'] : "")
                  ?.toString() ??
              "",
      userEmail: (hopper is Map ? hopper['email'] : "")?.toString() ?? "",
      userPhone: (hopper is Map ? hopper['phone'] : "")?.toString() ?? "",
      userAddress: (hopper is Map ? hopper['address'] : "")?.toString() ?? "",
      vat: json['Vat']?.toString() ?? "0.0",
      amount: json['amount']?.toString() ?? "0.0",
      allAmount: json['total_received_from_stripe']?.toString() ?? "0.0",
      totalEarningAmt: json['hopper_price']?.toString() ?? "0.0",
      payableT0Hopper: json['payable_to_hopper']?.toString() ?? "0.0",
      payableCommission: json['presshop_commission']?.toString() ?? "0.0",
      type: json['type'] ?? "",
      percentage: json['presshop_commission']?.toString() ?? "0.0",
      typesOfContent: false,
      createdAT: dateTimeFormatter(dateTime: json['createdAt'] ?? ""),
      dueDate: dateTimeFormatter(dateTime: json['Due_date'] ?? ""),
      updatedAT: dateTimeFormatter(dateTime: json['updatedAt'] ?? ""),
      companyLogo:
          (bankDetail is Map ? bankDetail['bank_logo'] : "")?.toString() ?? "",
      contentId: json['task_id'] ?? "",
      hopperAvatar:
          (hopper is Map ? hopper['avatar'] ?? hopper['profileImage'] : "")
                  ?.toString() ??
              "",
      hopperBankName:
          (bankDetail is Map ? bankDetail['bank_name'] : "")?.toString() ?? "",
      hopperBankLogo:
          (bankDetail is Map ? bankDetail['bank_logo'] : "")?.toString() ?? "",
      contentImage: json['purchased_task_content'] != null &&
              json['purchased_task_content'].isNotEmpty
          ? json['purchased_task_content'][0]['videothubnail'] ?? ""
          : "",
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] ?? '').toString(),
    );
  }
  String id = '';
  bool paidStatus = false;
  String adminFullName = "";
  String adminProfileImage = "";
  String adminCountryCode = "";
  String adminPhoneNumber = "";
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
  // int userPhone = 0;
  String userPhone = "";
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
  String mediaTypeImage = "";
  String currency = "";
  String currencySymbol = "";

  EarningTransaction toEntity() {
    return EarningTransaction(
      id: id,
      amount: amount,
      totalEarningAmt: totalEarningAmt,
      status: paidStatus ? "Paid" : "Pending",
      paidStatus: paidStatus,
      contentTitle: contentTitle,
      contentType: contentType,
      createdAt: createdAT,
      dueDate: dueDate,
      adminFullName: adminFullName,
      companyLogo: companyLogo,
      contentImage: contentImage,
      payableT0Hopper: payableT0Hopper,
      payableCommission: payableCommission,
      stripefee: stripefee,
      hopperBankLogo: hopperBankLogo,
      hopperBankName: hopperBankName,
      userFirstName: userFirstName,
      userLastName: userLastName,
      contentDataList: contentDataList,
      type: type,
      typesOfContent: typesOfContent,
      hopperAvatar: hopperAvatar,
      uploadContent: "",
      contentId: contentId,
      currency: currency,
      currencySymbol: currencySymbol,
    );
  }
}

class BankDataModel {
  BankDataModel({
    required this.isDefault,
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.sortCode,
    required this.accountNumber,
  });

  factory BankDataModel.fromJson(Map<String, dynamic> json) {
    return BankDataModel(
        isDefault: json['is_default'] ?? false,
        id: json['_id'] ?? '',
        accountHolderName: json['acc_holder_name'] ?? '',
        bankName: json['bank_name'] ?? '',
        sortCode: json['sort_code'] ?? '',
        accountNumber: json['acc_number'] ?? 0);
  }
  bool isDefault = false;
  String id = '';
  String accountHolderName = '';
  String bankName = '';
  String sortCode = '';
  int accountNumber = 0;
}

class FilterModel {
  FilterModel({
    required this.name,
    required this.icon,
    required this.isSelected,
    this.value,
    this.fromDate,
    this.toDate,
  });
  String name = "";
  String icon = "";
  String? value;
  String? fromDate;
  String? toDate;
  bool isSelected = false;
}
