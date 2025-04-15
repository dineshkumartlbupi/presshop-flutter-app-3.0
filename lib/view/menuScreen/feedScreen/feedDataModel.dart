/*class FeedDataModel {
   FirstLevelCheck firstLevelCheck;
   String saleStatus;
   String paymentPending;
   String pressshop;
   bool checkAndApprove;
   String mode;
   List<dynamic> tagIds;
   String type;
   String status;
   String favouriteStatus;
   bool isDraft;
   String paidStatus;
   PurchasedPublication purchasedPublication;
   bool paidStatusToHopper;
   dynamic contentUnderOffer;
   String id;
   String description;
   String location;
   double latitude;
   double longitude;
   CategoryId categoryId;
   int askPrice;
   DateTime timestamp;
   HopperId hopperId;
   List<ContentDataModel> contentDataList;
   DateTime createdAt;
   DateTime updatedAt;
   dynamic callTimeDate;
   String heading;
   String remarks;
   String secondLevelCheck;
   String userId;
   int amountPaid;
   //DateTime latestAdminUpdated;
   String FeedDataModelId;

   FeedDataModel({
      required this.firstLevelCheck,
      required this.saleStatus,
      required this.paymentPending,
      required this.pressshop,
      required this.checkAndApprove,
      required this.mode,
      required this.tagIds,
      required this.type,
      required this.status,
      required this.favouriteStatus,
      required this.isDraft,
      required this.paidStatus,
      required this.purchasedPublication,
      required this.paidStatusToHopper,
      required this.contentUnderOffer,
      required this.id,
      required this.description,
      required this.location,
      required this.latitude,
      required this.longitude,
      required this.categoryId,
      required this.askPrice,
      required this.timestamp,
      required this.hopperId,
      required this.contentDataList,
      required this.createdAt,
      required this.updatedAt,
      required this.callTimeDate,
      required this.heading,
      required this.remarks,
      required this.secondLevelCheck,
      required this.userId,
      required this.amountPaid,
      //required this.latestAdminUpdated,
      required this.FeedDataModelId,
   });

   factory FeedDataModel.fromJson(Map<String, dynamic> json){
       List<ContentDataModel> contentData = [];

       if(json['content'] != null){
          var data = json['content'] as List;
          contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
       }

      return FeedDataModel(
      firstLevelCheck: FirstLevelCheck.fromJson(json["firstLevelCheck"]),
      saleStatus: json["sale_status"] ?? "",
      paymentPending: json["payment_pending"] ?? "",
      pressshop: json["pressshop"] ?? "",
      checkAndApprove: json["checkAndApprove"] ?? false,
      mode: json["mode"] ?? "",
      tagIds: json["tag_ids"] ?? [],
      type: json["type"] ?? "",
      status: json["status"] ?? "",
      favouriteStatus: json["favourite_status"] ?? "",
      isDraft: json["is_draft"] ?? false,
      paidStatus: json["paid_status"]  ?? "",
      purchasedPublication: PurchasedPublication.fromJson(json["purchased_publication"] ?? {}),
      paidStatusToHopper: json["paid_status_to_hopper"] ?? false,
      contentUnderOffer: json["content_under_offer"] ?? "",
      id: json["_id"] ?? "",
      description: json["description"] ?? "",
      location: json["location"] ?? "",
      latitude: json["latitude"]?.toDouble() ?? 0.0,
      longitude: json["longitude"]?.toDouble() ?? 0.0,
      categoryId: CategoryId.fromJson(json["category_id"] ?? {}),
      askPrice: json["original_ask_price"] ?? 0,
      timestamp: DateTime.parse(json["timestamp"] ?? ""),
      hopperId: HopperId.fromJson(json["hopper_id"] ?? {}),
      contentDataList:contentData,
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      callTimeDate: json["call_time_date"] ?? "",
      heading: json["heading"] ?? "",
      remarks: json["remarks"] ?? "",
      secondLevelCheck: json["secondLevelCheck"] ?? "",
      userId: json["user_id"] ?? "",
      amountPaid: json["amount_paid"] ?? "",
      //latestAdminUpdated:json["latestAdminUpdated"] != null? DateTime.parse(json["latestAdminUpdated"]):"",
      FeedDataModelId: json["id"] ?? "",
   );}
}

class CategoryId {
   String percentage;
   String id;
   String type;
   String name;

   CategoryId({
      required this.percentage,
      required this.id,
      required this.type,
      required this.name,
   });

   factory CategoryId.fromJson(Map<String, dynamic> json) => CategoryId(
      percentage: json["percentage"] ?? "",
      id: json["_id"] ?? "",
      type: json["type"] ?? "",
      name: json["name"] ?? "",
   );

}

class ContentDataModel {
   String mediaType;
   String id;
   String media;

   ContentDataModel({
      required this.mediaType,
      required this.id,
      required this.media,
   });

   factory ContentDataModel.fromJson(Map<String, dynamic> json) => ContentDataModel(
      mediaType: json["media_type"] ?? "",
      id: json["_id"] ?? "",
      media: json["media"] ?? "",
   );
}

class FirstLevelCheck {
   bool nudity;
   bool isAdult;
   bool isGdpr;

   FirstLevelCheck({
      required this.nudity,
      required this.isAdult,
      required this.isGdpr,
   });

   factory FirstLevelCheck.fromJson(Map<String, dynamic> json) => FirstLevelCheck(
      nudity: json["nudity"],
      isAdult: json["isAdult"],
      isGdpr: json["isGDPR"],
   );
}

class HopperId {
   Location location;
   bool receiveTaskNotification;
   String category;
   double latitude;
   double longitude;
   String mode;
   String publishedContentAdminMode;
   String uploadedContentAdminMode;
   bool isSocialRegister;
   String role;
   bool isTermsAccepted;
   String status;
   String verification;
   bool checkAndApprove;
   bool isTempBlocked;
   bool isPermanentBlocked;
   DateTime latestAdminUpdated;
   String latestAdminRemark;
   bool verified;
   List<BankDetail> bankDetail;
   String id;
   String firstName;
   String lastName;
   String email;
   String countryCode;
   int phone;
   String address;
   AvatarId avatarId;
   String userName;
   int v;
   String userId;
   String publishedContentAdminEmployeeId;
   DateTime publishedContentAdminEmployeeIdDate;
   String publishedContentRemarks;
   String uploadedContentAdminEmployeeId;
   DateTime uploadedContentAdminEmployeeIdDate;
   String uploadedContentRemarks;
   String hopperIdId;

   HopperId({
      required this.location,
      required this.receiveTaskNotification,
      required this.category,
      required this.latitude,
      required this.longitude,
      required this.mode,
      required this.publishedContentAdminMode,
      required this.uploadedContentAdminMode,
      required this.isSocialRegister,
      required this.role,
      required this.isTermsAccepted,
      required this.status,
      required this.verification,
      required this.checkAndApprove,
      required this.isTempBlocked,
      required this.isPermanentBlocked,
      required this.latestAdminUpdated,
      required this.latestAdminRemark,
      required this.verified,
      required this.bankDetail,
      required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.countryCode,
      required this.phone,
      required this.address,
      required this.avatarId,
      required this.userName,
      required this.v,
      required this.userId,
      required this.publishedContentAdminEmployeeId,
      required this.publishedContentAdminEmployeeIdDate,
      required this.publishedContentRemarks,
      required this.uploadedContentAdminEmployeeId,
      required this.uploadedContentAdminEmployeeIdDate,
      required this.uploadedContentRemarks,
      required this.hopperIdId,
   });

   factory HopperId.fromJson(Map<String, dynamic> json){return
   HopperId(
      location: Location.fromJson(json["location"]),
      receiveTaskNotification: json["recieve_task_notification"],
      category: json["category"],
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
      mode: json["mode"],
      publishedContentAdminMode: json["published_content_admin_mode"],
      uploadedContentAdminMode: json["uploaded_content_admin_mode"],
      isSocialRegister: json["isSocialRegister"],
      role: json["role"],
      isTermsAccepted: json["is_terms_accepted"],
      status: json["status"],
      verification: json["verification"],
      checkAndApprove: json["checkAndApprove"],
      isTempBlocked: json["isTempBlocked"],
      isPermanentBlocked: json["isPermanentBlocked"],
      latestAdminUpdated: DateTime.parse(json["latestAdminUpdated"]),
      latestAdminRemark: json["latestAdminRemark"] ?? "",
      verified: json["verified"],
      bankDetail: List<BankDetail>.from(json["bank_detail"].map((x) => BankDetail.fromJson(x))),
      id: json["_id"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      countryCode: json["country_code"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      avatarId: AvatarId.fromJson(json["avatar_id"]),
      userName: json["user_name"] ?? "",
      v: json["__v"],
      userId: json["user_id"] ?? "",
      publishedContentAdminEmployeeId: json["published_content_admin_employee_id"] ?? "",
      publishedContentAdminEmployeeIdDate: DateTime.parse(json["published_content_admin_employee_id_date"]),
      publishedContentRemarks: json["published_content_remarks"] ?? "",
      uploadedContentAdminEmployeeId: json["uploaded_content_admin_employee_id"] ?? "",
      uploadedContentAdminEmployeeIdDate: DateTime.parse(json["uploaded_content_admin_employee_id_date"]),
      uploadedContentRemarks: json["uploaded_content_remarks"] ?? "",
      hopperIdId: json["id"] ?? "",
   );
}}

class AvatarId {
   bool deletedAt;
   String id;
   String avatar;
   DateTime createdAt;
   DateTime updatedAt;

   AvatarId({
      required this.deletedAt,
      required this.id,
      required this.avatar,
      required this.createdAt,
      required this.updatedAt,
   });

   factory AvatarId.fromJson(Map<String, dynamic> json) => AvatarId(
      deletedAt: json["deletedAt"],
      id: json["_id"],
      avatar: json["avatar"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
   );
}

class BankDetail {
   bool isDefault;
   String id;
   String accHolderName;
   String bankName;
   String sortCode;
   int accNumber;

   BankDetail({
      required this.isDefault,
      required this.id,
      required this.accHolderName,
      required this.bankName,
      required this.sortCode,
      required this.accNumber,
   });

   factory BankDetail.fromJson(Map<String, dynamic> json) => BankDetail(
      isDefault: json["is_default"],
      id: json["_id"],
      accHolderName: json["acc_holder_name"],
      bankName: json["bank_name"],
      sortCode: json["sort_code"],
      accNumber: json["acc_number"],
   );
}

class Location {
   String type;
   List<double> coordinates;

   Location({
      required this.type,
      required this.coordinates,
   });

   factory Location.fromJson(Map<String, dynamic> json) => Location(
      type: json["type"],
      coordinates: List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
   );
}

class PurchasedPublication {
   AdminDetail adminDetail;
   AdminRignts adminRignts;
   UploadDocs uploadDocs;
   CompanyBankDetails companyBankDetails;
   SignLeagelTerms signLeagelTerms;
   String userName;
   String mode;
   bool isAdministator;
   bool isResponsibleForUserRights;
   bool isResponsibleForGrantingPurchasing;
   bool isResponsibleForFixingMinimumAndMaximumFinancialLimits;
   bool isConfirm;
   bool isSocialRegister;
   String role;
   bool isTermsAccepted;
   String status;
   String verification;
   bool checkAndApprove;
   dynamic isTempBlocked;
   dynamic isPermanentBlocked;
   DateTime latestAdminUpdated;
   dynamic latestAdminRemark;
   bool verified;
   List<OfficeDetail> officeDetails;
   String id;
   int phone;
   String email;
   String fullName;
   String designationId;
   String companyName;
   String companyNumber;
   String companyVat;
   DateTime createdAt;
   DateTime updatedAt;
   int v;
   dynamic action;
   String sourceContentEmployee;
   String firstName;
   String lastName;
   String remarks;
   String profileImage;
   String purchasedPublicationId;

   PurchasedPublication({
      required this.adminDetail,
      required this.adminRignts,
      required this.uploadDocs,
      required this.companyBankDetails,
      required this.signLeagelTerms,
      required this.userName,
      required this.mode,
      required this.isAdministator,
      required this.isResponsibleForUserRights,
      required this.isResponsibleForGrantingPurchasing,
      required this.isResponsibleForFixingMinimumAndMaximumFinancialLimits,
      required this.isConfirm,
      required this.isSocialRegister,
      required this.role,
      required this.isTermsAccepted,
      required this.status,
      required this.verification,
      required this.checkAndApprove,
      required this.isTempBlocked,
      required this.isPermanentBlocked,
      required this.latestAdminUpdated,
      required this.latestAdminRemark,
      required this.verified,
      required this.officeDetails,
      required this.id,
      required this.phone,
      required this.email,
      required this.fullName,
      required this.designationId,
      required this.companyName,
      required this.companyNumber,
      required this.companyVat,
      required this.createdAt,
      required this.updatedAt,
      required this.v,
      required this.action,
      required this.sourceContentEmployee,
      required this.firstName,
      required this.lastName,
      required this.remarks,
      required this.profileImage,
      required this.purchasedPublicationId,
   });

   factory PurchasedPublication.fromJson(Map<String, dynamic> json) => PurchasedPublication(
      adminDetail: AdminDetail.fromJson(json["admin_detail"]),
      adminRignts: AdminRignts.fromJson(json["admin_rignts"]),
      uploadDocs: UploadDocs.fromJson(json["upload_docs"]),
      companyBankDetails: CompanyBankDetails.fromJson(json["company_bank_details"]),
      signLeagelTerms: SignLeagelTerms.fromJson(json["sign_leagel_terms"]),
      userName: json["user_name"],
      mode: json["mode"],
      isAdministator: json["is_administator"],
      isResponsibleForUserRights: json["is_responsible_for_user_rights"],
      isResponsibleForGrantingPurchasing: json["is_responsible_for_granting_purchasing"],
      isResponsibleForFixingMinimumAndMaximumFinancialLimits: json["is_responsible_for_fixing_minimum_and_maximum_financial_limits"],
      isConfirm: json["is_confirm"],
      isSocialRegister: json["isSocialRegister"],
      role: json["role"],
      isTermsAccepted: json["is_terms_accepted"],
      status: json["status"],
      verification: json["verification"],
      checkAndApprove: json["checkAndApprove"],
      isTempBlocked: json["isTempBlocked"],
      isPermanentBlocked: json["isPermanentBlocked"],
      latestAdminUpdated: DateTime.parse(json["latestAdminUpdated"]),
      latestAdminRemark: json["latestAdminRemark"],
      verified: json["verified"],
      officeDetails: List<OfficeDetail>.from(json["office_details"].map((x) => OfficeDetail.fromJson(x))),
      id: json["_id"] ?? "",
      phone: json["phone"] ?? "",
      email: json["email"] ?? "",
      fullName: json["full_name"] ?? "",
      designationId: json["designation_id"] ?? "",
      companyName: json["company_name"] ?? "",
      companyNumber: json["company_number"] ?? "",
      companyVat: json["company_vat"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      v: json["__v"] ?? "",
      action: json["action"] ?? "",
      sourceContentEmployee: json["source_content_employee"] ?? "",
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      remarks: json["remarks"] ?? "",
      profileImage: json["profile_image"] ?? "",
      purchasedPublicationId: json["id"] ?? "",
   );
}

class AdminDetail {
   String fullName;
   String officeType;
   String officeName;
   String department;
   String adminProfile;
   String countryCode;
   int phone;
   String email;

   AdminDetail({
      required this.fullName,
      required this.officeType,
      required this.officeName,
      required this.department,
      required this.adminProfile,
      required this.countryCode,
      required this.phone,
      required this.email,
   });

   factory AdminDetail.fromJson(Map<String, dynamic> json) => AdminDetail(
      fullName: json["full_name"],
      officeType: json["office_type"],
      officeName: json["office_name"],
      department: json["department"],
      adminProfile: json["admin_profile"],
      countryCode: json["country_code"],
      phone: json["phone"],
      email: json["email"],
   );
}

class AdminRignts {
   PriceRange priceRange;
   bool allowedToOnboardUsers;
   bool allowedToDeregisterUsers;
   bool allowedToAssignUsersRights;
   bool allowedToSetFinancialLimit;
   bool allowedCompleteAccess;
   bool allowedToBroadcastTasks;
   bool allowedToPurchaseContent;

   AdminRignts({
      required this.priceRange,
      required this.allowedToOnboardUsers,
      required this.allowedToDeregisterUsers,
      required this.allowedToAssignUsersRights,
      required this.allowedToSetFinancialLimit,
      required this.allowedCompleteAccess,
      required this.allowedToBroadcastTasks,
      required this.allowedToPurchaseContent,
   });

   factory AdminRignts.fromJson(Map<String, dynamic> json) => AdminRignts(
      priceRange: PriceRange.fromJson(json["price_range"]),
      allowedToOnboardUsers: json["allowed_to_onboard_users"],
      allowedToDeregisterUsers: json["allowed_to_deregister_users"],
      allowedToAssignUsersRights: json["allowed_to_assign_users_rights"],
      allowedToSetFinancialLimit: json["allowed_to_set_financial_limit"],
      allowedCompleteAccess: json["allowed_complete_access"],
      allowedToBroadcastTasks: json["allowed_to_broadcast_tasks"],
      allowedToPurchaseContent: json["allowed_to_purchase_content"],
   );
}

class PriceRange {
   int minimumPrice;
   int maximumPrice;

   PriceRange({
      required this.minimumPrice,
      required this.maximumPrice,
   });

   factory PriceRange.fromJson(Map<String, dynamic> json) => PriceRange(
      minimumPrice: json["minimum_price"],
      maximumPrice: json["maximum_price"],
   );
}

class CompanyBankDetails {
   bool isDefault;
   String companyAccountName;
   String bankName;
   String sortCode;
   String accountNumber;

   CompanyBankDetails({
      required this.isDefault,
      required this.companyAccountName,
      required this.bankName,
      required this.sortCode,
      required this.accountNumber,
   });

   factory CompanyBankDetails.fromJson(Map<String, dynamic> json) => CompanyBankDetails(
      isDefault: json["is_default"],
      companyAccountName: json["company_account_name"],
      bankName: json["bank_name"],
      sortCode: json["sort_code"],
      accountNumber: json["account_number"],
   );
}

class OfficeDetail {
   Address address;
   bool isAnotherOfficeExist;
   String id;
   String name;
   String officeTypeId;
   String countryCode;
   int phone;
   String website;

   OfficeDetail({
      required this.address,
      required this.isAnotherOfficeExist,
      required this.id,
      required this.name,
      required this.officeTypeId,
      required this.countryCode,
      required this.phone,
      required this.website,
   });

   factory OfficeDetail.fromJson(Map<String, dynamic> json) => OfficeDetail(
      address: Address.fromJson(json["address"]),
      isAnotherOfficeExist: json["is_another_office_exist"],
      id: json["_id"],
      name: json["name"],
      officeTypeId: json["office_type_id"],
      countryCode: json["country_code"],
      phone: json["phone"],
      website: json["website"],
   );
}

class Address {
   PinLocation pinLocation;
   Location location;
   int pincode;
   String country;
   String city;
   String completeAddress;

   Address({
      required this.pinLocation,
      required this.location,
      required this.pincode,
      required this.country,
      required this.city,
      required this.completeAddress,
   });

   factory Address.fromJson(Map<String, dynamic> json) => Address(
      pinLocation: PinLocation.fromJson(json["Pin_Location"]),
      location: Location.fromJson(json["location"]),
      pincode: json["pincode"],
      country: json["country"],
      city: json["city"],
      completeAddress: json["complete_address"],
   );
}

class PinLocation {
   double lat;
   double long;

   PinLocation({
      required this.lat,
      required this.long,
   });

   factory PinLocation.fromJson(Map<String, dynamic> json) => PinLocation(
      lat: json["lat"]?.toDouble(),
      long: json["long"]?.toDouble(),
   );
}

class SignLeagelTerms {
   bool isConditionOne;
   bool isConditionTwo;
   bool isConditionThree;

   SignLeagelTerms({
      required this.isConditionOne,
      required this.isConditionTwo,
      required this.isConditionThree,
   });

   factory SignLeagelTerms.fromJson(Map<String, dynamic> json) => SignLeagelTerms(
      isConditionOne: json["is_condition_one"] ?? false,
      isConditionTwo: json["is_condition_two"] ?? false,
      isConditionThree: json["is_condition_three"] ?? false,
   );
}

class UploadDocs {
   bool deleteDocWhenOnboadingCompleted;
   List<Document> documents;

   UploadDocs({
      required this.deleteDocWhenOnboadingCompleted,
      required this.documents,
   });

   factory UploadDocs.fromJson(Map<String, dynamic> json) => UploadDocs(
      deleteDocWhenOnboadingCompleted: json["delete_doc_when_onboading_completed"] ?? "",
      documents: List<Document>.from(json["documents"].map((x) => Document.fromJson(x))),
   );
}

class Document {
   List<String> url;
   String id;

   Document({
      required this.url,
      required this.id,
   });

   factory Document.fromJson(Map<String, dynamic> json) => Document(
      url: List<String>.from(json["url"].map((x) => x)),
      id: json["_id"] ?? "",
   );
}*/



class FeedsDataModel {
  bool firstLevelCheckNudity = false;
  bool firstLevelCheckAdult = false;
  bool firstLevelCheckGDPR = false;
  String saleStatus = "";
  String paymentPending = "";
  String pressshop = "";
  bool checkAndApprove = false;
  String mode = "";
  List<dynamic> tagIds = [];
  String type = "";
  String status = "";
  String favouriteStatus = "";
  bool isDraft = false;
  String paidStatus = "";
  bool paidStatusToHopper = false;
  String id = "";
  String description = "";
  String location = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String categoryPercentage = "";
  String categoryName = "";
  String categoryId = "";
  String categoryType = "";
  String askPrice = "";
  String timestamp;
  int viewCount = 0;
  int offerCount = 0;

  List<ContentDataModel> contentDataList = [];
  String createdAt;
  String updatedAt;
  String heading = "";
  String remarks = "";
  String userId;
  String amountPaid = '';
  String feedsDataModelId;
  bool showVideo = false;
  bool mostViewed = false;

  bool isFavourite = false;
  bool isLiked = false;
  bool isEmoji = false;
  bool isClap = false;

  FeedsDataModel({
    required this.firstLevelCheckNudity,
    required this.firstLevelCheckAdult,
    required this.firstLevelCheckGDPR,
    required this.saleStatus,
    required this.paymentPending,
    required this.pressshop,
    required this.checkAndApprove,
    required this.mode,
    required this.tagIds,
    required this.type,
    required this.status,
    required this.favouriteStatus,
    required this.isDraft,
    required this.paidStatus,
    required this.paidStatusToHopper,
    required this.id,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.categoryPercentage,
    required this.categoryName,
    required this.categoryType,
    required this.askPrice,
    required this.timestamp,
    required this.contentDataList,
    required this.createdAt,
    required this.updatedAt,
    required this.heading,
    required this.remarks,
    required this.userId,
    required this.amountPaid,
    required this.feedsDataModelId,
    required this.showVideo,
    required this.mostViewed,
    required this.isFavourite,
    required this.isLiked,
    required this.isEmoji,
    required this.isClap,
    required this.viewCount,
    required this.offerCount,
  });

  factory FeedsDataModel.fromJson(Map<String, dynamic> json) {
    List<ContentDataModel> contentData = [];
    if (json["content"] != null) {
      var data = json["content"] as List;
      contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
    }

    return FeedsDataModel(
      saleStatus: json["sale_status"] ?? "",
      paymentPending: json["payment_pending"] ?? "",
      pressshop: json["pressshop"] ?? "",
      checkAndApprove: json["checkAndApprove"] ?? "",
      mode: json["mode"] ?? "",
      tagIds: json["tag_ids"] ?? [],
      type: json["type"] ?? "",
      status: json["status"] ?? "",
      favouriteStatus: json["favourite_status"] ?? "",
      isDraft: json["is_draft"] ?? "",
      paidStatus: json["paid_status"] ?? "",
      paidStatusToHopper: json["paid_status_to_hopper"] ?? "",
      id: json["_id"] ?? "",
      description: json["description"] ?? "",
      location: json["location"] ?? "",
      latitude: json["latitude"]?.toDouble() ?? 0.0,
      longitude: json["longitude"]?.toDouble() ?? 0.0,
      categoryId: json['category_id']['_id'] ?? "",
      categoryName: json['category_id']['name'] ?? "",
      categoryPercentage: json['category_id']['percentage'] ?? "",
      categoryType: json['category_id']['type'] ?? "",
      askPrice: json["original_ask_price"].toString(),
      timestamp: json["timestamp"] ?? "",
      contentDataList: contentData,
      createdAt: json['createdAt'].toString(),
      updatedAt: json['updatedAt'] ?? "",
      heading: json["heading"] ?? "",
      remarks: json["remarks"] ?? "",
      userId: json["user_id"] ?? "",
      amountPaid: json["amount_paid"].toString() ?? '',
      feedsDataModelId: json["id"] ?? "",
      firstLevelCheckNudity: json['firstLevelCheck']['nudity'] ?? false,
      firstLevelCheckAdult: json['firstLevelCheck']['isAdult'] ?? false,
      firstLevelCheckGDPR: json['firstLevelCheck']['isGDPR'] ?? false,
      showVideo: false,
      mostViewed: false,
      isFavourite: json['is_favourite'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isEmoji: json['is_emoji'] ?? false,
      isClap: json['is_clap'] ?? false,
      // viewCount: json['count_for_hopper'] ?? 0,
      viewCount: json['content_view_count_by_marketplace_for_app'] ?? 0,
      offerCount: json["purchased_mediahouse"]!=null? (json["purchased_mediahouse"] as List).length: 0
    );
  }
}

class ContentDataModel {
  String mediaType = "";
  String id = "";
  String media = "";
  String thumbnail = "";

  ContentDataModel({
    required this.mediaType,
    required this.id,
    required this.media,
    required this.thumbnail,
  });

  factory ContentDataModel.fromJson(Map<String, dynamic> json) => ContentDataModel(
        mediaType: json["media_type"] ?? "",
        id: json["_id"] ?? "",
        media: json["media"] ?? "",
        thumbnail: json["thumbnail"] ?? "",
      );
}
