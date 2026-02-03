import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const adminBaseUrl = "https://dev-api.presshop.news:5020/";
const mediaBaseUrl = "https://dev-presshope.s3.eu-west-2.amazonaws.com/public/";
const socketUrl = "https://dev-api.presshop.news:3005";

// External Services
const googleMapURL =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json";
const googlePlaceDetailsURL =
    "https://maps.googleapis.com/maps/api/place/details/json";

// Media Paths

const profileImageUrl = "${mediaBaseUrl}userImages/";
const docImageUrl = "${mediaBaseUrl}docToBecomePro/";
const adminProfileUrl = "${mediaBaseUrl}adminImages/";

const contentImageUrl = "https://dev-cdn.presshop.news/public/contentData/";
const imageUrlBefore =
    "https://dev-api.presshop.news/presshop_rest_apis/public/contentData/";
const taskMediaUrl = "https://dev-cdn.presshop.news/public/uploadContent/";
const mediaThumbnailUrl = "https://dev-cdn.presshop.news/public/thumbnail/";

// ==============================================================================
// AUTHENTICATION & ONBOARDING
// =============================================================================

const appRefreshTokenUrl = "auth/refreshToken";
// ==============================================================================
// USER PROFILE & SETTINGS
// ==============================================================================

const myProfileUrl = "hopper/getUserProfile";
const editProfileUrl = "hopper/editHopper";
const changePasswordUrl = "users/changePassword";
const addBankUrl = "hopper/addUserBankDetails";
const bankListUrl = "hopper/getBankList";
const editBankUrl = "hopper/updateBankDetail";
const deleteBankUrl = "hopper/deleteBankDetail/";
const getUkBankListUrl = "hopper/getUkbankList";
const uploadCertificateUrl = "hopper/uploadDocToBecomePro";
const getUploadDocUrl = "hopper/getuploadedDocumentList";
const deleteDocUrl = "hopper/deleteDocument";
const uploadDocUrl = "hopper/uploadDocToBecomeProNew";
const deleteCertificateAPI = "hopper/deleteuploadDocToBecomePro";
const updateLocation = "hopper/updatelocation";
// const addDeviceUrl = "hopper/add/fcm/token";
const removeDeviceUrl = "hopper/remove/fcm/token";
const deleteAccountUrl = "hopper/verifyAndDeleteAccount";
const checkOnboardingCompleteOrNotUrl = "hopper/checkOnboardingCompleteOrNot";
const getAvatarsUrl = "admin/getAvatars";
const appSettingUrl = "hopper/appSettings";
const studentBeansActivationUrl = "hopper/studentBeansActivation";

// ==============================================================================
// CONTENT & MEDIA
// ==============================================================================

const uploadUserMediaUrl = "hopper/uploadUserMedia";
const uploadContentUrl = "hopper/uploadmedia";
const multipleImageUrl = "hopper/uploadMultipleImg";
const addContentUrl = "hopper/addContent";
const myContentUrl = "hopper/getContentList";
const allContentUrl = "hopper/getAllContent";
const myDraftUrl = "hopper/getDraftContentList";
const myContentDetailUrl = "hopper/getContentById/";
const removeFromDraftContentAPI = "hopper/updateDraft";
const getFeedListAPI = "hopper/getfeeds";
const likeFavFeedAPI = "hopper/updatefeed";
const getAllRatingAPI = "hopper/getallrating";
const addViewCountAPI = "hopper/mostviewed";
const getHashTagsUrl = "users/getTags";
const addHashTagsUrl = "users/addTag";
const categoryUrl = "users/getCategory/";
const getHopperCategory = "hopper/getCategory?";
const getAggregatedNewsUrl = "hopper/getAggregatedNews";
const getAggregatedNewsDetailUrl = "hopper/getAggregatedNewsDetail";
const getAggregatedNewsCommentsUrl = "hopper/getAggregatedNewsComments";

// ==============================================================================
// TASKS & JOBS
// ==============================================================================

const taskDetailUrl = "hopper/tasks/assigned/by/mediaHouse/";
const taskAcceptRejectRequestUrl = "hopper/tasks/request";
const getAllMyTaskUrl = "hopper/getAllmyTask";
const getAllTaskUrl = "hopper/getAllTask";
const uploadTaskMediaUrl = "hopper/addUploadedContent";
const getContentMediaHouseOfferUrl = "hopper/getallofferMediahouse";
const getMediaHouseDetailAPI = "hopper/getlistofmediahouse";
const getHopperAcceptedCountUrl = "hopper/acceptedHoppersdata";
const getTaskTransactionDetails = "hopper/getTaskTransactionDetails";

// ==============================================================================
// PAYMENTS & WALLET
// ==============================================================================

const createStripeAccount = "hopper/createStripeAccount";
const getEarningDataAPI = "hopper/getearning";
const getAllEarningTransactionAPI = "hopper/getalllistofEarning";
const getPublicationTransactionAPI = 'hopper/getallEarning/contentId';
const uploadStripeFiles = "hopper/uploadStipeFiles";
const updateStripeBankUrl = "hopper/fetchAndupdateBankdetails?";
const generateStripeBankApi = "hopper/add-express-bank-account";
const shareAndExclusivePriceUrl = "hopper/get/priceValue";
const priceTipsAPI = "hopper/getpriceTipforQuestion?";
const commissionGetUrl = "hopper/commissionHopperArmy";

// ==============================================================================
// CHAT & NOTIFICATIONS
// ==============================================================================

const getMediaTaskChatListUrl = "hopper/getAllchat";
const notificationListAPI = "hopper/getNotification";
const notificationReadAPI = "hopper/updatenotification";
const sendPushNotificationAPI = "hopper/sendPustNotificationByHopper";
const clearNotification = "hopper/updateNotificationforClearAll";
const myBroadCastChatRoomListUrl = "hopper/get/broadcast/room";
const broadCastRoomDetailUrl = "hopper/get/broadcast/group/chat";
const getRoomIdUrl = "hopper/create/room";
const sendAdminMessageUrl = "hopper/send/admin/broadcast/chat";
const readAdminMessageUrl = "hopper/read/admin/broadcast/chat/";
const addMessageApiUrl = "hopper/addchatbot";
const getMessageApiUrl = "hopper/getchatbotMessages";
const getOfferPaymentChat = "hopper/get-offer-payment-chat";
const sendchatInitToAdminUrl = "hopper/sendChatInitiatedMailToAdmin";
const allAlertUrl = "hopper/getHopperAlertList?";

// ==============================================================================
// MISCELLANEOUS & STATIC DATA
// ==============================================================================

const termConditionUrl = "users/getCMSForHopper";
const getAllCmsUrl = "hopper/getGenralMgmtApp?";
const adminDetailAPI = "hopper/adminDetails";
const signupLegalApi = 'hopper/legal';
const getDetailsById = "hopper/getdetailsbyid";
const allCharityUrl = "hopper/listofcharity?";
const leadershipurl = "hopper/getLeaderboardList";
const getAdminListUrl = "hopper/adminlist";
const onDeeplinkCallback = "admin/onDeeplinkCallback";
const onAppInstallCallback = "admin/onAppInstallCallback";

String get googleMapAPiKey {
  try {
    return dotenv.get('GOOGLE_MAP_API_KEY',
        fallback: "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI");
  } catch (_) {
    return "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
  }
}

String get appleMapAPiKey {
  try {
    return dotenv.get('APPLE_MAP_API_KEY',
        fallback: "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw");
  } catch (_) {
    return "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw";
  }
}

final String appUrl = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
    : 'https://apps.apple.com/in/app/presshop/id6744651614';
