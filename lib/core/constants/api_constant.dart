// import 'dart:io';

// /// ================= MAP & PLATFORM KEYS =================
// const googleMapAPiKey = "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
// const appleMapAPiKey = "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw";

// const googleMapURL =
//     "https://maps.googleapis.com/maps/api/place/autocomplete/json";

// /// ================= BASE URLS =================
// const baseUrl = "https://funnellike-subangular-sulema.ngrok-free.dev/api/";
// const adminBaseUrl = "https://datastream22843-r.presshop.news:7001/";
// const mediaBaseUrl = "https://livestreamdata-r.presshop.news/public/";
// const socketUrl = "https://datastream22843-r.presshop.news:4005";

// /// ================= MEDIA URLS =================
// const avatarImageUrl = "${mediaBaseUrl}avatarImages/";
// const profileImageUrl = "${mediaBaseUrl}userImages/";
// const docImageUrl = "${mediaBaseUrl}docToBecomePro/";
// const adminProfileUrl = "${mediaBaseUrl}adminImages/";
// const termConditionUrl = "users/getCMSForHopper";

// const contentImageUrl =
//     "https://livestreamdata-r.presshop.news/public/contentData/";
// const imageUrlBefore =
//     "https://dev-api.presshop.news/presshop_rest_apis/public/contentData/";
// const taskMediaUrl =
//     "https://livestreamdata-r.presshop.news/public/uploadContent/";
// const mediaThumbnailUrl =
//     "https://livestreamdata-r.presshop.news/public/thumbnail/";

// /// ================= APP URLS =================
// final String appUrl = Platform.isAndroid
//     ? "https://play.google.com/store/apps/details?id=com.presshop.app"
//     : "https://apps.apple.com/in/app/presshop/id6744651614";

// const oldappUrl = "https://developers.promaticstechnologies.com/";

// /// ================= AUTH APIs =================
// const sendOtpUrl = "auth/sendOTP";
// const verifyOtpUrl = "auth/verifyOTP";
// //const registerUrl = "auth/registerHopper";
// const loginUrl = "auth/login";
// const forgotPasswordUrl = "auth/hopper/forgotPassword";
// const resetPasswordUrl = "auth/hopper/resetPassword";
// const verifyForgotPasswordOTPUrl = "auth/hopper/verifyForgotPasswordOTP";
// const socialLoginRegisterUrl = "auth/hopper/socialRegister";
// const socialExistUrl = "auth/hopper/socialLogin";
// const referralUrl = "auth/hopper/verifyReferralCode";
// const verifyReferredCodeUrl = "auth/hopper/verifyReferredCode";
// const appRefreshTokenUrl = "auth/refreshToken";
// const getLatestVersionUrl = "auth/getLatestVersion";
// const checkAppInstallFirstTimeIrNotUrl = "auth/isDeviceExist?device_id=";

// /// ================= USER & PROFILE APIs =================
// const myProfileUrl = "hopper/getUserProfile";
// const editProfileUrl = "hopper/editHopper";
// const deleteAccountUrl = "hopper/verifyAndDeleteAccount";
// const updateLocation = "hopper/updatelocation";
// const checkOnboardingCompleteOrNotUrl = "hopper/checkOnboardingCompleteOrNot";

// const checkUserNameUrl = "users/checkIfUserNameExist/";
// const checkEmailUrl = "users/checkIfEmailExist/";
// const checkPhoneUrl = "users/checkIfPhoneExist/";
// const categoryUrl = "users/getCategory/";
// const getAvatarsUrl = "users/getAvatars";

// /// ================= BANK & STRIPE APIs =================
// const addBankUrl = "hopper/addUserBankDetails";
// const bankListUrl = "hopper/getBankList";
// const editBankUrl = "hopper/updateBankDetail";
// const deleteBankUrl = "hopper/deleteBankDetail/";
// const getUkBankListUrl = "hopper/getUkbankList";

// const createStripeAccount = "hopper/createStripeAccount";
// const uploadStripeFiles = "hopper/uploadStipeFiles";
// const updateStripeBankUrl = "hopper/fetchAndupdateBankdetails?";
// const generateStripeBankApi = "hopper/add-express-bank-account";

// /// ================= CONTENT & MEDIA APIs =================
// const addContentUrl = "hopper/addContent";
// const uploadContentUrl = "hopper/uploadMedia";
// const uploadTaskMediaUrl = "hopper/addUploadedContent";
// const uploadUserMediaUrl = "hopper/uploadUserMedia";
// const multipleImageUrl = "hopper/uploadMultipleImg";

// const myContentUrl = "hopper/getContentList";
// const allContentUrl = "hopper/getAllContent";
// const myDraftUrl = "hopper/getDraftContentList";
// const myContentDetailUrl = "hopper/getContentById/";
// const removeFromDraftContentAPI = "hopper/updateDraft";

// /// ================= DOCUMENT APIs =================
// const uploadCertificateUrl = "hopper/uploadDocToBecomePro";
// const deleteCertificateAPI = "hopper/deleteuploadDocToBecomePro";
// const uploadDocUrl = "hopper/uploadDocToBecomeProNew";
// const getUploadDocUrl = "hopper/getuploadedDocumentList";
// const deleteDocUrl = "hopper/deleteDocument";

// /// ================= TASK & OFFER APIs =================
// const taskDetailUrl = "hopper/tasks/assigned/by/mediaHouse/";
// const taskAcceptRejectRequestUrl = "hopper/tasks/request";
// const getAllMyTaskUrl = "hopper/getAllmyTask";
// const getAllTaskUrl = "hopper/getAllTask";
// const getContentMediaHouseOfferUrl = "hopper/getallofferMediahouse";
// const getTaskTransactionDetails = "hopper/getTaskTransactionDetails";
// const getOfferPaymentChat = "hopper/get-offer-payment-chat";

// /// ================= FEED & INTERACTION APIs =================
// const getFeedListAPI = "hopper/getfeeds";
// const likeFavFeedAPI = "hopper/updatefeed";
// const addViewCountAPI = "hopper/mostviewed";

// /// ================= CHAT & BROADCAST APIs =================
// const getRoomIdUrl = "hopper/create/room";
// const getMediaTaskChatListUrl = "hopper/getAllchat";
// const addMessageApiUrl = "hopper/addchatbot";
// const getMessageApiUrl = "hopper/getchatbotMessages";

// const myBroadCastChatRoomListUrl = "hopper/get/broadcast/room";
// const broadCastRoomDetailUrl = "hopper/get/broadcast/group/chat";
// const sendAdminMessageUrl = "hopper/send/admin/broadcast/chat";
// const readAdminMessageUrl = "hopper/read/admin/broadcast/chat/";
// const sendchatInitToAdminUrl = "hopper/sendChatInitiatedMailToAdmin";

// /// ================= NOTIFICATION APIs =================
// const notificationListAPI = "hopper/getNotification";
// const notificationReadAPI = "hopper/updatenotification";
// const clearNotification = "hopper/updateNotificationforClearAll";
// const sendPushNotificationAPI = "hopper/sendPustNotificationByHopper";
// const allAlertUrl = "hopper/getHopperAlertList?";

// /// ================= EARNING & RATING APIs =================
// const getEarningDataAPI = "hopper/getearning";
// const getAllEarningTransactionAPI = "hopper/getalllistofEarning";
// const getPublicationTransactionAPI = "hopper/getallEarning/contentId";
// const commissionGetUrl = "hopper/commissionHopperArmy";
// const getAllRatingAPI = "hopper/getallrating";
// const leadershipurl = "hopper/getLeaderboardList";

// /// ================= CMS, SETTINGS & MISC =================
// const getAllCmsUrl = "hopper/getGenralMgmtApp?";
// const appSettingUrl = "hopper/appSettings";
// const priceTipsAPI = "hopper/getpriceTipforQuestion?";
// const shareAndExclusivePriceUrl = "hopper/get/priceValue";
// const signupLegalApi = "hopper/legal";
// const allCharityUrl = "hopper/listofcharity?";

// /// ================= ADMIN & CALLBACK APIs =================
// const adminDetailAPI = "hopper/adminDetails";
// const getAdminListUrl = "hopper/adminlist";
// const onDeeplinkCallback = "admin/onDeeplinkCallback";
// const onAppInstallCallback = "admin/onAppInstallCallback";

// const getContentMediaHouseOfferReq = 40;
// const reqGetPublicationTransactionReq = 49;
