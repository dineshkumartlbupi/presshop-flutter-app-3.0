import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstantsNew {
  ApiConstantsNew._();
  static const Config config = Config();
  static const Auth auth = Auth();
  static const Profile profile = Profile();
  static const Content content = Content();
  static const Tasks tasks = Tasks();
  static const Payments payments = Payments();
  static const Chat chat = Chat();
  static const Misc misc = Misc();
}

class Config {
  const Config();
  static const int env = 1;

  // ====================== Ngrok Url =====================
  // String get baseUrl =>
  //     "https://lelia-anthracitic-ecclesiologically.ngrok-free.dev/api/";

  // String get socketUrl2 =>
  //     "wss://lelia-anthracitic-ecclesiologically.ngrok-free.dev";

  // ====================== Ngrok Url =====================
  String get baseUrl =>
      "https://funnellike-subangular-sulema.ngrok-free.dev/api/";
  String get socketUrl2 => "wss://funnellike-subangular-sulema.ngrok-free.dev";

// ====================== Localhost Url =====================

  // String get baseUrl => "http://localhost:8100/api/";
  // String get socketUrl2 => "http://localhost:8100";

  // ====================== AWS Url =====================
  // String get baseUrl => "http://18.170.92.207:8100/api/";

  // String get socketUrl2 => "wss://18.170.92.207:8100/api/";

  String get googleMapURL =>
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";
  String get googlePlaceDetailsURL =>
      "https://maps.googleapis.com/maps/api/place/details/json";

  // API Keys
  String get googleMapApiKey {
    try {
      return dotenv.get(
        'GOOGLE_MAP_API_KEY',
        fallback: 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI',
      );
    } catch (_) {
      return 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
    }
  }

  String get appleMapApiKey {
    try {
      return dotenv.get(
        'APPLE_MAP_API_KEY',
        fallback: 'AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw',
      );
    } catch (_) {
      return 'AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw';
    }
  }

  String get appUrl => Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
      : 'https://apps.apple.com/in/app/presshop/id6744651614';
}

class Auth {
  const Auth();
  final String sendOtp = "auth/sendOTP";
  final String verifyOtp = "auth/verifyOTP";
  final String register = "auth/registerHopper";
  final String login = "auth/login";
  final String socialRegister = "auth/hopper/socialRegister";
  final String socialLogin = "auth/hopper/socialLogin";
  final String forgotPassword = "auth/hopper/forgotPassword";
  final String resetPassword = "auth/hopper/resetPassword";
  final String verifyForgotOtp = "auth/hopper/verifyForgotPasswordOTP";
  final String refreshToken = "auth/refreshToken";
  final String verifyReferral = "auth/hopper/verifyReferralCode";
  final String verifyReferredCode = "auth/hopper/verifyReferredCode";
  final String getLatestVersion = "auth/getLatestVersion";
  final String checkUserName = "admin/checkIfUserNameExist/:username";
  final String checkEmail = "admin/checkIfEmailExist/:email";
  final String checkPhone = "admin/checkIfPhoneExist/:phone";
  final String checkAppInstallFirstTime = "auth/isDeviceExist?device_id=";
  final String checkAppVersion = "hopper/check/version";
}

class Profile {
  const Profile();

  final String myProfile = "hopper/getUserProfile";
  final String editProfile = "hopper/editHopper";
  final String changePassword = "users/changePassword";
  final String addBank = "hopper/addUserBankDetails";
  final String bankList = "hopper/getBankList";
  final String updateBank = "hopper/updateBankDetail";
  final String deleteBank = "hopper/deleteBankDetail/";
  final String getUkBankList = "hopper/getUkbankList";
  final String uploadDocument = "hopper/uploadDocToBecomePro";
  final String uploadDocNew = "hopper/uploadDocToBecomeProNew";
  final String getUploadedDocs = "hopper/getuploadedDocumentList";
  final String deleteDocument = "hopper/deleteDocument";
  final String deleteCertificate = "hopper/deleteuploadDocToBecomePro";
  final String getAvatars = "users/getAvatars";
  final String updateLocation = "hopper/updatelocation";
  final String addDevice = "hopper/add/fcm/token";
  final String removeDevice = "hopper/remove/fcm/token";
  final String deleteAccount = "hopper/verifyAndDeleteAccount";
  final String onboardingStatus = "hopper/checkOnboardingCompleteOrNot";
  final String appSettings = "hopper/appSettings";
  final String studentBeansActivation = "hopper/studentBeansActivation";
}

class Content {
  const Content();

  final String uploadUserMedia = "hopper/uploadUserMedia";
  final String uploadChatAttachment = "hopper/uploadChatAttachment";
  final String uploadMedia = "hopper/uploadmedia";
  final String uploadMultipleImages = "hopper/uploadMultipleImg";
  final String addContent = "hopper/addContent";
  // final String myContent = "hopper/getHopperContentList";
  final String myContent = "hopper/getContentList";
  final String allContent = "hopper/getAllContent";
  final String draftContent = "hopper/getDraftContentList";
  final String contentDetail = "hopper/getContentById/";
  final String removeFromDraft = "hopper/updateDraft";
  final String feedList = "hopper/getfeeds";
  final String likeFeed = "hopper/updatefeed";
  final String getAllRating = "hopper/getallrating";
  final String mostViewed = "hopper/mostviewed";
  final String aggregatedNews = "hopper/getAggregatedNewss";
  final String aggregatedNewsDetail = "hopper/getAggregatedNewsDetail";
  final String aggregatedNewsComments = "hopper/getAggregatedNewsComments";
  final String getTags = "users/getTags";
  final String addTags = "users/addTag";
  final String category = "users/getCategory/";
  final String hopperCategory = "hopper/getCategory?";

  // Chunked Upload Endpoints
  final String initiateUpload = "media/initiate-upload";
  final String completeUpload = "media/complete-upload";
  final String abortUpload = "media/abort-upload";
  final String mediaStatus = "media/status/";
}

class Tasks {
  const Tasks();

  final String assignedTaskDetail = "hopper/tasks/assigned/by/mediaHouse/";
  final String acceptRejectTask = "hopper/tasks/request";
  final String myTasks = "hopper/getAllmyTask";
  final String allTasks = "hopper/getAllTask";
  final String uploadTaskMedia = "hopper/addUploadedContent";
  final String mediaHouseOffer = "hopper/getallofferMediahouse";
  final String mediaHouseList = "hopper/getlistofmediahouse";
  final String acceptedHopperCount = "hopper/acceptedHoppersdata";
  final String transactionDetails = "hopper/getTaskTransactionDetails";
}

class Payments {
  const Payments();

  final String createStripeAccount = "hopper/createStripeAccount";
  final String uploadStripeFiles = "hopper/uploadStipeFiles";
  final String updateStripeBank = "hopper/fetchAndupdateBankdetails?";
  final String addExpressBank = "hopper/add-express-bank-account";
  final String earnings = "hopper/getearning";
  final String earningTransactions = "hopper/getalllistofEarning";
  final String publicationTransaction = "hopper/getallEarning/contentId";
  final String priceValue = "hopper/get/priceValue";
  final String priceTips = "hopper/getpriceTipforQuestion?";
  final String commission = "hopper/commissionHopperArmy";
}

class Chat {
  const Chat();
  final String chatList = "hopper/getAllchat";
  final String roomHistory = "hopper/get-room-chat";
  final String notificationList = "hopper/getNotification";
  final String notificationRead = "hopper/updatenotification";
  final String sendPushNotification = "hopper/sendPushNotificationByHopper";
  final String clearNotification = "hopper/updateNotificationforClearAll";
  final String broadcastRoomList = "hopper/get/broadcast/room";
  final String broadcastRoomDetail = "hopper/get/broadcast/group/chat";
  final String createRoom = "hopper/create/room";
  final String sendAdminMessage = "hopper/send/admin/broadcast/chat";
  final String readAdminMessage = "hopper/read/admin/broadcast/chat/";
  final String addChatbotMessage = "hopper/addchatbot";
  final String getChatbotMessages = "hopper/getchatbotMessages";
  final String getOfferPaymentChat = "hopper/get-offer-payment-chat";
  final String sendChatInitToAdmin = "hopper/sendChatInitiatedMailToAdmin";
  final String sendChatMessage = "hopper/send/chat/message";
  final String allAlerts = "hopper/getHopperAlertList?";
  final String getAlertIncidents = "hopper/getAlertIncidents";
  final String updateAlertView = "hopper/updateAlertView";
}

class Misc {
  const Misc();
  final String cms = "users/getCMSForHopper";
  final String generalMgmt = "hopper/getGenralMgmtApp?";
  final String adminDetails = "hopper/adminDetails";
  final String signupLegal = "hopper/legal";
  final String getDetailsById = "hopper/getdetailsbyid";
  final String leaderboard = "hopper/getLeaderboardList";
  final String adminList = "hopper/adminlist";
  final String charityList = "hopper/listofcharity?";
  final String onDeeplinkCallback = "admin/onDeeplinkCallback";
  final String onAppInstallCallback = "admin/onAppInstallCallback";
}
