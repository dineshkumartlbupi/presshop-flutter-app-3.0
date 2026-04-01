import 'package:flutter/cupertino.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/feed/presentation/pages/feed_data_model.dart';
import '../../domain/entities/earning_transaction.dart';

class EarningProfileDataModel {
  final String id;
  final Hopper hopper;
  final MediaHouse mediaHouse;
  final double amount;
  final double presshopCommission;
  final double payableToHopper;
  final double stripeFee;
  final double totalEarning;
  final double monthlyEarning;
  final String currency;
  final String currencySymbol;
  final PaymentMethod paymentMethod;
  final String invoiceNumber;
  final String? dueDate;
  final bool paidStatusForHopper;
  final DateTime createdAt;

  EarningProfileDataModel({
    required this.id,
    required this.hopper,
    required this.mediaHouse,
    required this.amount,
    required this.presshopCommission,
    required this.payableToHopper,
    required this.stripeFee,
    required this.totalEarning,
    required this.monthlyEarning,
    required this.currency,
    required this.currencySymbol,
    required this.paymentMethod,
    required this.invoiceNumber,
    this.dueDate,
    required this.paidStatusForHopper,
    required this.createdAt,
  });

  factory EarningProfileDataModel.fromJson(Map<String, dynamic> json) {
    return EarningProfileDataModel(
      id: json['_id'] ?? '',
      hopper: Hopper.fromJson(json['hopper_id'] ?? {}),
      mediaHouse: MediaHouse.fromJson(json['media_house_id'] ?? {}),
      amount: (json['amount'] ?? 0).toDouble(),
      presshopCommission: (json['presshop_commission'] ?? 0).toDouble(),
      payableToHopper: (json['payable_to_hopper'] ?? 0).toDouble(),
      stripeFee: (json['stripe_fee'] ?? 0).toDouble(),
      totalEarning: (json['total_earning'] ?? 0).toDouble(),
      monthlyEarning: (json['monthly_earning'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      currencySymbol: json['currency_symbol'] ?? '',
      paymentMethod: PaymentMethod.fromJson(json['payment_method'] ?? {}),
      invoiceNumber: json['invoiceNumber'] ?? '',
      dueDate: json['Due_date'],
      paidStatusForHopper: json['paid_status_for_hopper'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'hopper_id': hopper.toJson(),
      'media_house_id': mediaHouse.toJson(),
      'amount': amount,
      'presshop_commission': presshopCommission,
      'payable_to_hopper': payableToHopper,
      'stripe_fee': stripeFee,
      'total_earning': totalEarning,
      'monthly_earning': monthlyEarning,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'payment_method': paymentMethod.toJson(),
      'invoiceNumber': invoiceNumber,
      'Due_date': dueDate,
      'paid_status_for_hopper': paidStatusForHopper,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  EarningProfileDataModel copyWith({
    String? id,
    Hopper? hopper,
    MediaHouse? mediaHouse,
    double? amount,
    double? presshopCommission,
    double? payableToHopper,
    double? stripeFee,
    double? totalEarning,
    double? monthlyEarning,
    String? currency,
    String? currencySymbol,
    PaymentMethod? paymentMethod,
    String? invoiceNumber,
    String? dueDate,
    bool? paidStatusForHopper,
    DateTime? createdAt,
  }) {
    return EarningProfileDataModel(
      id: id ?? this.id,
      hopper: hopper ?? this.hopper,
      mediaHouse: mediaHouse ?? this.mediaHouse,
      amount: amount ?? this.amount,
      presshopCommission: presshopCommission ?? this.presshopCommission,
      payableToHopper: payableToHopper ?? this.payableToHopper,
      stripeFee: stripeFee ?? this.stripeFee,
      totalEarning: totalEarning ?? this.totalEarning,
      monthlyEarning: monthlyEarning ?? this.monthlyEarning,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      dueDate: dueDate ?? this.dueDate,
      paidStatusForHopper: paidStatusForHopper ?? this.paidStatusForHopper,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MediaHouse {
  final String id;
  final String firstName;
  final String lastName;

  MediaHouse({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory MediaHouse.fromJson(Map<String, dynamic> json) {
    return MediaHouse(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

class Hopper {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String avatar;

  Hopper({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.avatar,
  });

  factory Hopper.fromJson(Map<String, dynamic> json) {
    return Hopper(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
    };
  }
}

class PaymentMethod {
  final String id;
  final CardDetails card;
  final BillingDetails billingDetails;

  PaymentMethod({
    required this.id,
    required this.card,
    required this.billingDetails,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      card: CardDetails.fromJson(json['card'] ?? {}),
      billingDetails: BillingDetails.fromJson(json['billing_details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card': card.toJson(),
      'billing_details': billingDetails.toJson(),
    };
  }
}

class CardDetails {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  CardDetails({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      brand: json['brand'] ?? '',
      last4: json['last4'] ?? '',
      expMonth: json['exp_month'] ?? 0,
      expYear: json['exp_year'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
    };
  }
}

class BillingDetails {
  final String name;
  final String email;
  final Address address;

  BillingDetails({
    required this.name,
    required this.email,
    required this.address,
  });

  factory BillingDetails.fromJson(Map<String, dynamic> json) {
    return BillingDetails(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'address': address.toJson(),
    };
  }
}

class Address {
  final String city;
  final String country;
  final String postalCode;

  Address({
    required this.city,
    required this.country,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'postal_code': postalCode,
    };
  }
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
      amount = (double.tryParse(totalAmount.toString()) ?? 0.0) -
          (double.tryParse(vatFee.toString()) ?? 0.0);
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
            contentsImage = images.first["watermark"]?.toString() ??
                images.first["thumbnail"]?.toString() ??
                "";
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

    String parseAmount(dynamic val) {
      if (val == null) return "0.0";
      double? parsed = double.tryParse(val.toString());
      return parsed?.toString() ?? "0.0";
    }

    return EarningTransactionDetail(
        id: json['_id']?.toString() ?? '',
        mediaTypeImage: "",
        totalEarningAmt: json['type'] == 'task_content'
            ? parseAmount(json['hopper_price'] ??
                json['payable_to_hopper'] ??
                json['amount'])
            : parseAmount(json['original_ask_price'] ??
                json['payable_to_hopper'] ??
                json['amount']),
        paidStatus: json['paid_status_for_hopper'] ?? false,
        adminFullName: adminName,
        adminProfileImage: adminProfile,
        adminCountryCode: (mediaHouse is Map ? mediaHouse['country_code'] : '')
                ?.toString() ??
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
            ? json["received_bank_detail"]["bank_name"]?.toString() ?? ""
            : "",
        hopperBankLogo: json["received_bank_detail"] != null
            ? json["received_bank_detail"]["bank_logo"]?.toString() ?? ""
            : "",
        vat: parseAmount(vatFee),
        allAmount: parseAmount(totalAmount ?? json['amount']),
        payableT0Hopper: parseAmount(json['payable_to_hopper']),
        payableCommission: parseAmount(json['presshop_commission']),
        stripefee: parseAmount(json['stripe_fee']),
        type: json['type']?.toString() ?? '',
        percentage: parseAmount(json['percentage']),
        typesOfContent: json['typeofcontent'] == "shared" ? false : true,
        createdAT: dateTimeFormatter(
            dateTime: json['createdAt']?.toString() ?? ""),
        updatedAT: dateTimeFormatter(
            dateTime: json['updatedAt']?.toString() ?? ""),
        dueDate: json['Due_date']?.toString() ?? "",
        contentId: cId,
        amount: parseAmount(amount),
        contentTitle: cTitle,
        contentImage: contentsImage,
        currency: (json['currency'] ?? '').toString(),
        currencySymbol: (json['currency_symbol'] != null &&
                json['currency_symbol'].toString().isNotEmpty)
            ? json['currency_symbol'].toString()
            : getCurrencySymbol(json['currency']?.toString()),
        adminUserName: '');
  }

  factory EarningTransactionDetail.taskFromJson(Map<String, dynamic> json) {
    final hopper = json['hopper_id'];
    final bankDetail = json['received_bank_detail'];

    String parseAmount(dynamic val) {
      if (val == null) return "0.0";
      double? parsed = double.tryParse(val.toString());
      return parsed?.toString() ?? "0.0";
    }

    return EarningTransactionDetail(
      contentTitle: "",
      id: json['_id']?.toString() ?? "",
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
      stripefee: parseAmount(json['stripe_fee']),
      contentType: json['type']?.toString() ?? "",
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
      vat: parseAmount(json['Vat']),
      amount: parseAmount(json['amount']),
      allAmount: parseAmount(json['total_received_from_stripe']),
      totalEarningAmt: parseAmount(json['hopper_price']),
      payableT0Hopper: parseAmount(json['payable_to_hopper']),
      payableCommission: parseAmount(json['presshop_commission']),
      type: json['type']?.toString() ?? "",
      percentage: parseAmount(json['presshop_commission']),
      typesOfContent: false,
      createdAT:
          dateTimeFormatter(dateTime: json['createdAt']?.toString() ?? ""),
      dueDate: dateTimeFormatter(dateTime: json['Due_date'] ?? ""),
      updatedAT:
          dateTimeFormatter(dateTime: json['updatedAt']?.toString() ?? ""),
      companyLogo:
          (bankDetail is Map ? bankDetail['bank_logo'] : "")?.toString() ?? "",
      contentId: json['task_id']?.toString() ?? "",
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
          ? json['purchased_task_content'][0]['videothubnail']?.toString() ?? ""
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
