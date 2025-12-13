import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleMapAPiKey => dotenv.get('GOOGLE_MAP_API_KEY', fallback: "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI");
String get appleMapAPiKey => dotenv.get('APPLE_MAP_API_KEY', fallback: "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw");

//--------production urls----------------

// const baseUrl = "https://datastream22843-r.presshop.news:6003/";
// const adminBaseUrl = "https://datastream22843-r.presshop.news:7001/";

// const mediaBaseUrl = "https://livestreamdata-r.presshop.news/public/";

// const googleMapURL =
//     "https://maps.googleapis.com/maps/api/place/autocomplete/json";

// const avatarImageUrl = "${mediaBaseUrl}avatarImages/";
// const profileImageUrl = "${mediaBaseUrl}userImages/";
// const docImageUrl = "${mediaBaseUrl}docToBecomePro/";

// const contentImageUrl =
//     "https://livestreamdata-r.presshop.news/public/contentData/";

// const imageUrlBefore =
//     "https://dev-api.presshop.news/presshop_rest_apis/public/contentData/";

// const taskMediaUrl =
//     "https://livestreamdata-r.presshop.news/public/uploadContent/";

// const mediaThumbnailUrl =
//     "https://livestreamdata-r.presshop.news/public/thumbnail/";

// const adminProfileUrl = "${mediaBaseUrl}adminImages/";

// const oldappUrl = "https://developers.promaticstechnologies.com/";

// const socketUrl = "https://datastream22843-r.presshop.news:4005";

//===========url-endpoint============



//--------production urls----------------

const baseUrl = "https://dev-api.presshop.news:5019/";
const adminBaseUrl = "https://dev-api.presshop.news:5020/";

const mediaBaseUrl = "https://dev-presshope.s3.eu-west-2.amazonaws.com/public/";
const googleMapURL =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json";

const avatarImageUrl = "${mediaBaseUrl}avatarImages/";
const profileImageUrl = "${mediaBaseUrl}userImages/";
const docImageUrl = "${mediaBaseUrl}docToBecomePro/";

const contentImageUrl = "https://dev-cdn.presshop.news/public/contentData/";
const imageUrlBefore =
    "https://dev-api.presshop.news/presshop_rest_apis/public/contentData/";

const taskMediaUrl = "https://dev-cdn.presshop.news/public/uploadContent/";
const mediaThumbnailUrl = "https://dev-cdn.presshop.news/public/thumbnail/";
const adminProfileUrl = "${mediaBaseUrl}adminImages/";
const socketUrl = "https://dev-api.presshop.news:3005";



const checkUserNameUrl = "users/checkIfUserNameExist/";
const checkUserNameUrlRequest = 1;

const getAvatarsUrl = "users/getAvatars";
const getAvatarsUrlRequest = 2;

final String appUrl = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
    : 'https://apps.apple.com/in/app/presshop/id6744651614';

const getAllCmsUrl = "hopper/getGenralMgmtApp?";
const getAllCmsUrlRequest = 3;

const sendOtpUrl = "auth/sendOTP";
const sendOtpUrlRequest = 4;

const verifyOtpUrl = "auth/verifyOTP";
const verifyOtpUrlRequest = 5;

const registerUrl = "auth/registerHopper";
const registerUrlRequest = 6;

const myProfileUrl = "hopper/getUserProfile";
const myProfileUrlRequest = 7;

const addBankUrl = "hopper/addUserBankDetails";
const addBankUrlRequest = 8;

const checkEmailUrl = "users/checkIfEmailExist/";
const checkEmailUrlRequest = 9;

const checkPhoneUrl = "users/checkIfPhoneExist/";
const checkPhoneUrlRequest = 10;

const loginUrl = "auth/login";
const loginUrlRequest = 11;

const bankListUrl = "hopper/getBankList";
const bankListUrlRequest = 12;

const editBankUrl = "hopper/updateBankDetail";
const editBankUrlRequest = 13;

const deleteBankUrl = "hopper/deleteBankDetail/";
const deleteBankUrlRequest = 14;

const editProfileUrl = "hopper/editHopper";
const editProfileUrlRequest = 16;

const categoryUrl = "users/getCategory/";
const categoryUrlRequest = 17;

const uploadCertificateUrl = "hopper/uploadDocToBecomePro";
const uploadCertificateUrlRequest = 18;

const changePasswordUrl = "users/changePassword";
const changePasswordUrlRequest = 19;

const forgotPasswordUrl = "auth/hopper/forgotPassword";
const forgotPasswordUrlRequest = 20;

const resetPasswordUrl = "auth/hopper/resetPassword";
const resetPasswordUrlRequest = 21;

const getHashTagsUrl = "users/getTags";
const getHashTagsUrlRequest = 22;
const searchHashTagsUrlRequest = 23;

const addHashTagsUrl = "users/addTag";
const addHashTagsUrlRequest = 24;

const addContentUrl = "hopper/addContent";
const addContentUrlRequest = 25;

const socialLoginRegisterUrl = "auth/hopper/socialRegister";
const socialLoginRegisterUrlRequest = 26;

const socialExistUrl = "auth/hopper/socialLogin";
const socialExistUrlRequest = 27;

const myContentUrl = "hopper/getContentList";
const myContentUrlRequest = 28;

const allContentUrl = "hopper/getAllContent";
const allContentUrlRequest = 90;

const myDraftUrl = "hopper/getDraftContentList";
const myDraftUrlRequest = 28;

const myContentDetailUrl = "hopper/getContentById/";
const myContentDetailUrlRequest = 29;

const addDeviceUrl = "hopper/add/fcm/token";
const addDeviceUrlRequest = 30;

const taskDetailUrl = "hopper/tasks/assigned/by/mediaHouse/";
const taskDetailUrlRequest = 31;

const taskAcceptRejectRequestUrl = "hopper/tasks/request";
const taskAcceptRejectRequestReq = 32;

const getAllMyTaskUrl = "hopper/getAllmyTask";
const getAllMyTaskReq = 33;

const getAllTaskUrl = "hopper/getAllTask";
const getAllTaskReq = 190;

const uploadTaskMediaUrl = "hopper/addUploadedContent";
const uploadTaskMediaReq = 34;

const getAdminListUrl = "hopper/adminlist";
const getAdminListReq = 35;

const getRoomIdUrl = "hopper/create/room";
const getRoomIdReq = 36;

const getHopperAcceptedCountUrl = "hopper/acceptedHoppersdata";
const getHopperAcceptedCountReq = 37;

const uploadContentUrl = "hopper/uploadMedia";
const uploadContentReq = 38;

const getMediaTaskChatListUrl = "hopper/getAllchat";
const getMediaTaskChatListReq = 39;

const getContentMediaHouseOfferUrl = "hopper/getallofferMediahouse";
const getContentMediaHouseOfferReq = 40;

const getFeedListAPI = "hopper/getfeeds";
const reqFeedList = 41;

const getHopperCategory = "hopper/getCategory?";
const reqGetHopperCategory = 41;

const contactUSAPI = "hopper/Addcontact_us";
const reqContactUSAPI = 42;

const adminDetailAPI = "hopper/adminDetails";
const reqAdminDetailAPI = 43;

const priceTipsAPI = "hopper/getpriceTipforQuestion?";
const reqPriceTipsAPI = 44;

const notificationListAPI = "hopper/getNotification";
const reqNotificationListAPI = 45;

const createStripeAccount = "hopper/createStripeAccount";
const reqCreateStipeAccount = 46;

const getEarningDataAPI = "hopper/getearning";
const reqGetEarningDataAPI = 47;

const getAllEarningTransactionAPI = "hopper/getalllistofEarning";
const reqGetAllEarningTransactionAPI = 48;

const getPublicationTransactionAPI = 'hopper/getallEarning/contentId';
const reqGetPublicationTransactionReq = 49;

const likeFavFeedAPI = "hopper/updatefeed";
const reqLikeFavFeedAPI = 50;

const getAllRatingAPI = "hopper/getallrating";
const reqGetAllRatingAPI = 51;

const removeFromDraftContentAPI = "hopper/updateDraft";
const reqRemoveFromDraftContentAPI = 52;

const notificationReadAPI = "hopper/updatenotification";
const reqNotificationReadAPI = 53;

const getMediaHouseDetailAPI = "hopper/getlistofmediahouse";
const reqGetMediaHouseDetailAPI = 54;

const addViewCountAPI = "hopper/mostviewed";
const reqAddViewCountAPI = 55;

const sendPushNotificationAPI = "hopper/sendPustNotificationByHopper";
const reqSendPushNotificationAPI = 56;

const deleteCertificateAPI = "hopper/deleteuploadDocToBecomePro";
const reqDeleteCertificateAPI = 57;

const signupLegalApi = 'hopper/legal';
const signupLegalReq = 58;

const removeDeviceUrl = "hopper/remove/fcm/token";
const removeDeviceReq = 59;

const updateLocation = "hopper/updatelocation";
const updateLocationRequest = 60;

const clearNotification = "hopper/updateNotificationforClearAll";
const reqClearNotification = 61;

const uploadStripeFiles = "hopper/uploadStipeFiles";
const reqUploadStripeFiles = 62;

const getDetailsById = "hopper/getdetailsbyid";
const reqGetDetailsById = 63;

const updateStripeBankUrl = "hopper/fetchAndupdateBankdetails?";
const updateStripeBankReq = 64;

const allCharityUrl = "hopper/listofcharity?";
const allCharityReq = 65;

const verifyForgotPasswordOTPUrl = "auth/hopper/verifyForgotPasswordOTP";
const verifyForgotPasswordOTPReq = 66;

const deleteAccountUrl = "hopper/verifyAndDeleteAccount";
const deleteAccountUrlReq = 78;

const checkAppVersionUrl = "hopper/check/version";
const checkAppVersionReq = 68;

const myBroadCastChatRoomListUrl = "hopper/get/broadcast/room";
const myBroadCastChatRoomListReq = 69;

const appSettingUrl = "hopper/appSettings";
const appSettingReq = 70;

const shareAndExclusivePriceUrl = "hopper/get/priceValue";
const shareAndExclusivePriceReq = 71;

const broadCastRoomDetailUrl = "hopper/get/broadcast/group/chat";
const broadCastRoomDetailReq = 72;

const sendAdminMessageUrl = "hopper/send/admin/broadcast/chat";
const sendAdminMessageReq = 73;

const readAdminMessageUrl = "hopper/read/admin/broadcast/chat/";
const readAdminMessageReq = 74;

const referralUrl = "auth/hopper/verifyReferralCode";
const referralReq = 75;

const multipleImageUrl = "hopper/uploadMultipleImg";
const multipleImageReq = 66;

const allAlertUrl = "hopper/getHopperAlertList?";
const allAlertReq = 67;

const getUploadDocUrl = "hopper/getuploadedDocumentList";
const getUploadDocReq = 68;

const deleteDocUrl = "hopper/deleteDocument";
const deleteDocReq = 69;

const uploadDocUrl = "hopper/uploadDocToBecomeProNew";
const uploadDocReq = 70;

const checkOnboardingCompleteOrNotUrl = "hopper/checkOnboardingCompleteOrNot";
const checkOnboardingCompleteOrNotReq = 71;

const checkAppInstallFirstTimeIrNotUrl = "auth/isDeviceExist?device_id=";
const checkAppInstallFirstTimeIrNotReq = 72;

const getUkBankListUrl = "hopper/getUkbankList";
const getUkBankListUrlReq = 73;

const addMessageApiUrl = "hopper/addchatbot";
const addMessageApiReq = 74;

const getMessageApiUrl = "hopper/getchatbotMessages";
const getMessageApiReq = 75;

const getOfferPaymentChat = "hopper/get-offer-payment-chat";
const getOfferPaymentChatReq = 76;

const getTaskTransactionDetails = "hopper/getTaskTransactionDetails";
const getTaskTransactionDetailsReq = 77;

const generateStripeBankApi = "hopper/add-express-bank-account";
const generateStripeBankUrlRequest = 79;

const verifyReferredCodeUrl = "auth/hopper/verifyReferredCode";
const verifyReferredCodeUrlRequest = 80;

const commissionGetUrl = "hopper/commissionHopperArmy";
const commissionGetRequest = 81;

const getLatestVersionUrl = "auth/getLatestVersion";
const getLatestVersionReq = 82;

const sendchatInitToAdminUrl = "hopper/sendChatInitiatedMailToAdmin";
const sendchatInitToAdminReq = 83;

const onDeeplinkCallback = "admin/onDeeplinkCallback";
const onDeeplinkCallbackReq = 84;

const onAppInstallCallback = "admin/onAppInstallCallback";
const onAppInstallCallbackReq = 85;

const appRefreshTokenUrl = "auth/refreshToken";
const appRefreshTokenReq = 86;

const leadershipurl = "hopper/getLeaderboardList";
const leadershipReq = 87;

const studentBeansActivationUrl = "hopper/studentBeansActivation";
const studentBeansActivationRequest = 89;

const uploadUserMediaUrl = "hopper/uploadUserMedia";
const uploadUserMediaReq = 100;
