import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:presshop/main.dart';
import 'package:share_plus/share_plus.dart';

//const googleMapAPiKey = "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
const googleMapAPiKey = "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
//const appleMapAPiKey = "AIzaSyAIaPQyvLdlGaTG-AgFe0rzAlAkGK-JIJI";
const appleMapAPiKey = "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw";

//--------production urls----------------

// const baseUrl = "https://datastream22843-r.presshop.news:6003/";

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

//--------staging urls----------------
const baseUrl = "https://dev-api.presshop.news:5019/";

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

String get appUrl => Platform.isAndroid
    ? "https://play.google.com/store/apps/details?id=com.presshop.app"
    : "https://apps.apple.com/in/app/presshop/id6744651614";

/*const getAllCmsUrl = "users/getCMSForHopper";
const getAllCmsUrlRequest = 3;*/

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

/*const faqUrl = "users/getPriceTipAndFAQs/";
const faqUrlRequest = 15;*/

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

const GetDetailsById = "hopper/getdetailsbyid";
const reqGetDetailsById = 63;

/// aditya
const updateStripeBankUrl = "hopper/fetchAndupdateBankdetails?";
const updateStripeBankReq = 64;

const allCharityUrl = "hopper/listofcharity?";
const allCharityReq = 65;

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

const deleteAccountUrl = "hopper/verifyAndDeleteAccount";
const deleteAccountUrlReq = 78;

const generateStripeBankApi = "hopper/add-express-bank-account";
const generateStripeBankUrlRequest = 79;

const verifyReferredCodeUrl = "auth/hopper/verifyReferredCode";
const verifyReferredCodeUrlRequest = 80;

const commissionGetUrl = "hopper/commissionHopperArmy";
const commissionGetRequest = 81;

///--------------------------------------------------------------

const dummyImagePath = "assets/dummyImages/";
const commonImagePath = "assets/commonImages/";
const iconsPath = "assets/icons/";
const audioPath = "audio/";
const chatIconsPath = "assets/chatIcons";

var passwordExpression =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

var emailExpression = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

var hashExpression = RegExp(r'^[^#]*$');
/*-----CommonText--------*/
const walk1Title1Text = "CONNECT DIRECTLY";
const walk1Title2Text = "WITH THE PRESS";
const walk1DescriptionText =
    "Sell your content, and directly interact with leading publications around the World";

const walk2Title1Text = "TAKE A PIC OR";
const walk2Title2Text = "VIDEO";
const walk2DescriptionText =
    "Shoot pics and videos of incidents you see in your everyday life, on your mobile";
const walk2ButtonText = "Go on, take a pic";

const walk3Title1Text = "SELL YOUR CONTENT";
const walk3Title2Text = "TO THE PRESS";
const walk3DescriptionText =
    "Upload, and sell your content anonymously to hundreds of registered publications on our market-place";
const walk3ButtonText = "Sell your pics now";

const walk4Title1Text = "ACCEPT TASKS";
const walk4Title2Text = "& EARN MONEY ";
const walk4DescriptionText =
    "Accept broadcasted tasks, take pics, videos and interviews for the press & earn thousands of Pounds instantly";
const walk4ButtonText = "Start accepting tasks";

const walk5Title1Text = "KEEP TRACK OF YOUR";
const walk5Title2Text = " FUNDS";
const walk5DescriptionText =
    "View your earnings, payments due to you, and keep track of your money on the app";
const walk5ButtonText = "Start earning money";

const walk6Title1Text = "CONNECT WITH OUR";
const walk6Title2Text = "GROWING TRIBE";
const walk6DescriptionText =
    "View sold content, check what other users have earned, interact, learn & grow with the community";
const walk6ButtonText = "Join our tribe";

const skipText = "Skip";
const nextText = "Next";
const textData =
    "We hope you're enjoying your experience with PressHop. Please share your feedback with us. Your insights will help us enhance both your experience, and the quality of our service. Thank you!";
const goodMorningText = "Good morning";
const loginSubTitleText =
    "Welcome back, you were missed. Please hop right back in";
const loginUserHint = "Enter user name / phone number";
const enterPasswordHint = "Enter password";
const enterNewPasswordHint = "Enter new password";
const requiredText = "Required";
const validUserNameOrPhoneText = "Please enter valid user name or phone number";
const passwordErrorText =
    "Your password must be at least 8 characters in length";
const forgotPasswordText = "Forgot password";
const confirmPasswordErrorText = "Password doesn't match";
const signInText = "Sign In";
const orText = "or";
const nameHint = "Enter user name";
const continueGoogleText = "Continue with Google";
const donotHaveAccountText = "Don't have an account?";
const clickHereToJoinText = " Click here to join the tribe";
const emailErrorText = "Please enter a valid email address";
const bankErrorText = "Please enter minimum 8 digits";
const sortCodeErrorText = "Please enter a valid sort code";
const phoneErrorText = "Please enter a valid phone number";
const phoneExistsErrorText = "The phone number already exists";
const emailExistsErrorText = "The email address already exists";
const weakText = "Weak";
const strongText = "Strong";
const yesText = "Yes";
const noText = "No";
const passwordStrengthText = "Password strength";
const resetPasswordText = "Reset Password";
const otpExpireText = "The OTP will expire in";
const minutesText = "minutes";
const minuteText = "minute";
const secondsText = "seconds";
const otpNotReceivedText = "Didn't receive the OTP? No worries,";
const anotherOneText = "for another one\!";
const verifyYourAccountText = "Verify your accounts";
const addBankDetailsText = "Add bank details";
const accountHolderNameText = "Account Holder's Name";
const bankText = "Bank";
const sortCodeText = "Sort Code";
const accountNumberText = "Account Number";
const enterAccountHolderNameText = "Enter Account Holder's Name";
const enterBankText = "Enter Bank Name";
const enterSortCodeText = "Enter Sort Code";
const enterAccountNumberText = "Enter Account Number";
const setAsDefaultText = "Set as default account";
const tcText = "T&Cs";
const defaultText = "Default";
const declinedText = "declined";
const declineText = "decline";
const tcDeclinedNoteText =
    "You have declined accepting our legal T&Cs. Our legal terms need to be accepted to proceed ahead. Thank you";
const addBankDetailsSubHeadingText =
    "Please add & verify your bank details where you wish to receive your funds.";
const verifyMobileSubHeadingText =
    "Please enter the 5 digit OTP received on your registered mobile number";
const resetPasswordSubHeading =
    "Please enter the 5 digit OTP received on your registered email address";
const forgotPasswordSubHeading =
    "Don't worry, it happens to all of us! Please enter your registered email address to reset your password";
const uploadDocsHeadingText = 'Upload documents to become a PRO';
const uploadDocsSubHeading1Text =
    "If you're a professional photographer or journalist, and want to sign up as a";
const uploadDocsSubHeading2Text = "please upload your docs for review.";
const uploadDocsSubHeading3Text =
    "Once your docs are approved, you will qualify as a";
const uploadDocsSubHeading4Text = "and be eligible for attractive";
const uploadDocsSubHeading5Text =
    "If you are not a professional photographer, simply press finish to hop abroad. Cheers!";
const uploadYourDocumentsText = "Upload your documents";
const hiText = "Hi";
const welcomeToText = "welcome to";
const donateYourEarningsToCharityText = "Donate your earnings to charity";
const chooseYourCharityText = "Choose your charity";
const thankYouForDonatingCharityText =
    "Thank you for your donation. After deducting applicable PressHop commission and processing fees, the balance will be paid to your bank account and/or your chosen charity ❤";
const presshopText = "PressHop";
const welcomeSubTitleText =
    "Woohoo! You're a Hopper now. You can now anonymously sell your content, receive tasks from hundreds of publications, and earn loads of money while having fun.";
const welcomeSubTitle1Text = "You are successfully onboarded as a Hopper";
const acceptedTermsText = "Accepted terms and conditions";
const verifiedAccountText = "Verified your account";
const addedBankDetailsText = "Added bank details to start receiving money";
const uploadedDocumentsProText = "Uploaded documents if you're a PRO";
const anyText = "any 2 ";
const govIdText = "Government ID";
const passportText = "Passport";
const driverLicenseText = "Driver's License";
const photographyLicenseText = "Photography License";
const companyIncorporationText = "Company incorporation certificate";
const benefitText = "benefits";
const uploadText = "Upload";
const finishText = "Finish";
const myAccountText = "My Account";
const cameraText = "Camera";
const earningsText = "Earnings";
const myText = "My";
const taskText = "Task";
const chatText = "Chat";
const menuText = "Menu";
const digitalId = "Digital ID";
const notesText = "Notes";
const scanText = "Scan";
const photoText = "Photo";
const videoText = "Video";
const audioText = "Audio";
const galleryText = "Gallery";
const publishContentText = "Publish Content";
const publishContentHintText =
    "Please describe what you saw. Type here, or speak below. Cheers!";

const locationText = "Location";
const speakText = "Speak";
const timestampText = "Timestamp";
const hashtagText = "Hashtag";
const categoryText = "Category";
const chooseHowSellText = "Choose how you'll sell";
const sharedText = "Shared";
const exclusiveText = "Exclusive";
const amountQuoted = "Amount quoted";
const recommendedPriceText = "Recommended Price";
const publishContentSellNote1Text =
    "Sell your pics & videos to multiple publications for a lower price. You earn every time your content is purchased.";
const publishContentSellNote2Text =
    "Sell your pics & videos exclusively to a single publication, for a higher price. Once sold, the publication will retain exclusive publishing rights for 24 hours";
const enterYourPriceText = "Enter your price";
const checkText = "Check";
const priceTipsText = "Price Tips";
const privacyLawText = "Privacy law";
const learningText = "Learnings";
const tutorialsText = "Tutorials";
const contactText = "Contact ";
const usText = "us";
const publishContentFooter1Text =
    "Pricing your content correctly is key - check our ";
const publishContentFooter2Text = "&";
const publishContentFooter3Text =
    "to get it right. We uphold the highest standards of ethical journalism, so please review our";
const publishContentFooter4Text = "before submitting. Need assistance? Please ";
const publishContentFooter5Text = "our team 24/7. Thanks!";
const shareContextText =
    "Tied up right now? No problem! Why not share the PressHop app with family and friends so the next time you’re busy, they could accept the task & earn money. Spread the word, share the earnings🩷 with the Share The App CTA";

const saveText = "save";
const draftText = "draft";
const sellText = "sell";
const searchText = "Search";
const validText = "Valid";
const ratingText = "Ratings";
const pdfView = "PDF View";
const reviewText = "Reviews";
const receivedText = "Received";
const givenText = "Given";
const myProfileText = "My profile";
const editProfileText = "Edit profile";
const myDraftText = "My drafts";
const myContentText = "My content";
const contentText = "Content";
const detailsText = "details";
const stayLoggedInText = "Stay Logged In";
const okText = "Ok";
const feedText = "Feed";
const paymentMethodText = "Manage payments with Stripe";
const legalText = "Legal";
const logoutText = "Logout";
const accountSettingText = "Account settings";
const joinedText = "Joined";
const userText = "user";
const firstText = "first";
const lastText = "last";
const nameText = "name";
const phoneText = "Phone";
const emailAddressText = "Email address";
const houseText = "house";
const numberText = "number";
const streetText = "street";
const postalCodeText = "Post code";
const cityText = "City";
const countryText = "Country";
const enterText = "Enter";
const mostViewedText = "Most Viewed";
const youHaveEarnedText = "You've earned";
const priceQuotedText = "Price quoted";
const yourEarningsText = "Your earnings";
const presshopFeesText = "PressHop fees";
const presshopCommissionText = "PressHop commission";
const processingFeeText = "Processing fees";
const amountPaidText = "Amount payable";
const paymentMadeToText = "Payment made to";
const accountNoText = "Amount no";
const paymentDateText = "Payment date";
const dateofSaleText = "Date of sale";
const paymentText = "Payment";
const paymentMadeTimeText = "Payment made time";
const transactionIDText = "Transaction ID";
const amountPendingText1 = "Amount pending";
const amountPendingText = "Payment pending";
const paymentDueDateText = "Payment due date";
const paymentSummaryText = "Payment Summary";
const pendingText = "Pending";
const paymentDetailText = "Payment Detail";
const paymentPendingText = "Payments pending";
const transactionIdText = "Transaction ID";
const viewDetailsText = "View details";
const transactionDetails = "Transaction details";
const viewPublicationsPurchasedText =
    "View publications who have purchased your content";
const viewYourEarnings = "View your earnings";
const changePasswordText = "Change password";
const enterCurrentPasswordHintText = "Enter Current password";
const currentPasswordText = "Current password";
const newPasswordText = "New password";
const confirmNewPasswordText = "Confirm new password";
const myEarningsText = "My Earnings";
const docViewer = "Document Review";
const fromDateText = "From date";
const paymentReceivedText = "Payments received";
const commissionEarnedText = "Commission earned";
const toDateText = "To date";
const sortText = "Sort";
const filterText = "Filter";
const applyText = "Apply";
const fromText = "From";
const changePasswordSubTitleText =
    "Please enter a memorable password that you will remember. If you forget your password, you can always reset it again";
const publicationsListText = "Publications List";
const publicationsText = "Publications";
const publicationsListHeadingText =
    "Here’s a summary of the publications who have purchased your content";
const newBroadcastedTask = "New broadcasted task";
const youWIllBeMissedText = "You'll be missed";
const errorDialogText = "Oh-snap, the dreaded";
const logoutMessageText =
    "Are you sure you want to log out? You will no longer be able to sell your pics or videos to the press, and earn money!";
const deleteAccountPopupMessageText =
    "Are you sure you want to delete account? You will no longer be able to sell your pics or videos to the press, and earn money!";

const deadLineText = "deadline";
const viewText = "View";
const taskDetailText = "Task Details";
const pictureText = "Picture";
const interviewText = "Interview";
const offeredText = "Offered";
const uploadedContentText = "Uploaded content";
const manageTaskText = "Manage Task";
const manageContentText = "Manage Content";
const myBanksText = "My Banks";
const paymentMethods = "Manage payments with Stripe";
const messageText = "message";
const liveChatText = "Live Chat";
const emailUsText = "Email Us";
const faqText = "FAQs";
const average = "Average";
const contentSubmittedText = "Content Submitted";
const contentSubmittedHeadingText =
    "Hurrah! Your content has been successfully submitted.";

const contentBetaSubmittedHeadingText =
    "Smashing effort! Keep it coming, we’re almost live!";

const contentBetaSubmittedMessageText =
    "Thanks for your upload — you’re already a Star Hopper in the making! \nWe’re not quite live yet (official launch - end of July 2025), so submissions aren’t active just yet. But this is exactly the spirit we love — sharp eyes, quick taps, and early legends warming up for the main event. \nYou’ll be the first to know when we go fully live. We’ll drop you a push notification and an email the moment the doors open — and from then on, it’s game on. Snap. Submit. Sell.\nIn the meantime, have a look  around the app, practise taking your shots, and get ready to become a successful citizen journalist.\n";
const contentSubmittedMessageText =
    "Your content is being checked by our team for authenticity, and";
const contentSubmittedMessage1Text =
    "requirements. We may have to contact you on your registered mobile number to verify this content. Once the content is approved, it will be automatically published on our market place, and you will be notified.";
const contentSubmittedMessage2Text =
    "If you have any questions, please read our";
const contentSubmittedMessage3Text =
    "our team members who will be glad to help.";
const String deleteAccountText =
    "We’re sorry to see you go! If you choose to delete your account, it will be permanently removed from our system. Your phone number and email address will also be permanently erased. Are you absolutely certain you want to leave us forever?";

const boardCastShareSubText =
    "If you're unavailable or busy, you can share the task with someone you know, and let them earn extra money on the side. Go on, share the fun!";
const shareText = "Share";
const notificationText = "Notifications";

const digitalIdExpireOnText = "Digital ID expires on ";
const digitalIdText = "Digital ID";
const verifiedHopperText = "Verified Hopper";
const addLatestPhotoText = "Add your\nlatest photo";
const chooseYourAvatarText = "Choose your Avatar";
const chooseAvatarText = "Choose avatar";
const selectOptionText = "Select option";
const mediaUk = "Presso Media UK Limited";
const companyName = "Company # 135 22 872";

/*-----End--------*/

/*-----Vishal--------*/
const signUpText = 'Sign Up';
const firstNameHintText = 'Enter first name';
const lastNameHintText = 'Enter last name';
const userNameHintText = 'Enter user name';
const referralCodeHintText = "Enter referral code";
const phoneHintText = 'Enter phone number';
const emailHintText = 'Enter email';
const apartmentNoHintText = 'Apartment number / House name';
const emailAddressHintText = 'Enter email address';
const addressHintText = 'Enter house name/number';
const streetHintText = 'Enter street name';
const addressText = 'Address';
const cityHintText = 'Enter city';
const postalCodeHintText = 'Enter post code';
const countryHintText = 'Enter country';
const passwordHintText = 'Enter password';
const confirmPwdHintText = 'Confirm password';
const selectDobHintText = 'Select date of birth';
const signUpSubTitleText =
    'Join our growing tribe, and connect directly with the press.';
const userNameNoteText =
    'User name once chosen, cannot be changed. Any part of your real name is not allowed for security reasons';

const referralcodeNoteText =
    'Got a referral code? Drop it here to join the Hopper Army and start earning side by side!';
const enableNotificationText =
    'Enable notifications on your phone to receive tasks from the publications';
const chooseAvatarNoteText =
    "We only allow Avatars for interaction with the publications. This is to protect your identity at all times";

const clickHereToAgreeText = 'Click here, to agree to our';
const clickHereText = 'Click here';
const termsAndConditionText = 'Terms & Conditions';
const andText = 'and';
const viewsText = 'view';
const privacyPolicyText = 'Privacy Policy';
const submitText = 'Submit';
const publishText = 'Publish';
const continueWithGoogleText = 'Continue with Google';
const alreadyHaveAccountText = 'Already have an account?';
const legalDescText =
    'Please read and accept the below mentioned terms & conditions, and privacy policy to proceed';
const pleaseConfirmText =
    'Please confirm that you’ve read our terms & conditions, and our privacy policy by accepting all the conditions below';
const acceptText = 'Accept';
const rejectText = 'Reject';

//dummy String
const legalDummyText = 'Updated on 15 January, 2023';
const dummyPrivacyText =
    'We respect your privacy and are committed to protecting your personal information. Please refer to our privacy policy for details on how we collect, use, and protect your information.';
const dummyTermText =
    'You agree to use our app in a responsible manner and not to engage in any conduct that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable.';
const whatPrivacyDummyText = 'Privacy';
const userConductDummyText = 'User Conduct';
const checkBoxDummyText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.';
const contentDummyText =
    "Vivamus sit amet commodo risus. Ut dictum rutrum lacinia. Ut at nunc a mi facilisis ornare. Nullam arcu odio, volutpat at sem volutpat, imperdiet maximus nisi. Curabitur elit nulla, dictum a congue a, maximus vel elit. Donec dapibus est dapibus odio consectetur, a auctor erat tristique. Cras sed mattis ipsum.  Vivamus sit amet commodo risus. Ut dictum rutrum lacinia. Ut at nunc a mi facilisis ornare. Nullam arcu odio, volutpat at sem volutpat, imperdiet maximus nisi. Curabitur elit nulla, dictum a congue a, maximus vel elit. Donec dapibus est dapibus odio consectetur, a auctor erat tristique. Cras sed mattis ipsum.";

/*-----END-----------*/

/*----Sidharth-----*/

/// @ Sid
const toText = "To";

/// Sid 10 Mar 2023
const updateText = "Update";
const viewWeeklyText = "View weekly";
const viewMonthlyText = "View monthly";
const currentMontText = "Current month";
const viewYearlyText = "View yearly";
const filterDateText = "Date";
const allContentsText = "All contents";
const allTasksText = "All tasks";
const liveContentText = "Live content";
const liveTaskText = "Live content";
const soldContentText = "Sold content";
const allExclusiveContentText = "All exclusive content";
const allSharedContentText = "All shared content";
const paymentsReceivedText = "Payments received";
const pendingPaymentsText = "Pending payments";
const transactionDetailsText = "Transaction Details";
const taskCompletedText = "Task completed";
const contentCompletedText = "Content completed";
const timeAndDateText = "Time and date";
const offeredAmountText = "Offered amount";
const contentSoldText = "Content sold";
const soldText = "Sold";
const dateOfSaleText = "Date of sale";
const deadlineText = "DEADLINE";
// const declineText = "Decline";
//const acceptAndGoText = "Accept & Go";
const searchHintText = "Search";
const chatWithPRESSHOPText = "Chat with PressHop"; //client asked to lowercase
const chatWithPublicationsText = "Chat with publications";
const contentsText = "Contents";
const multipleText = "Multiple";
const offerText = "offer";
const sold = "sold";
const clearAllText = "Clear all";

/// Client Provided String
const contactUsSubmitMessage =
    "Thank you for contacting us. We will get back very soon. Cheers!";
const uploadDocErrorMessage =
    "Due to a technical error, this document was not uploaded. Please try again. Thanks";
const uploadDocMessage = "Thank you for uploading your documents";
const errorOpenSMS =
    "Due to a technical error, your SMS application can't be opened. Please try again!";
const errorOpenWhatsapp =
    "Due to a technical error, your Whatsapp application can't be opened. Please try again!";

const dummyNewsCompanyName = "Reuters News Agency";
const dummyNewsHeadline =
    '''Cate Blanchett and Rihanna while filming Oceans Eight''';
const dummyNewsDes =
    "Vivamus sit amet commodo risus. Ut dictum rutrum lacinia. Ut at nunc a mi facilisis ornare. Nullam arcu odio, volutpat at sem volutpat, imperdiet maximus nisi. Curabitur elit nulla, dictum a congue a, maximus vel elit. Donec dapibus est dapibus odio consectetur, a auctor erat tristique. Cras sed mattis ipsum. ";

const chooseCurrencyText = "Choose currency";

get referInviteText =>
    "wants you to join the PressHop revolution.🤳\n\n📱Welcome to the world’s most powerful citizen journalism app where everyday people like us, can earn real money by selling  stories, photos and videos anonymously to the press🛵.\n\n👀All you need is your phone and a sharp eye — no degrees, licences, or investment. Just point, shoot, and start earning cash💸.\n\n👇 Download the app now and get started: $appUrl\n\n 🪖Use this referral code when signing up:";

/*------------*/

/*-----DummyText-----*/
const copyRightText = "Copyright and licensing";
/*----End---------*/

/*--CommonKeys--*/

const unPaidText = "un_paid";
const paidText = "paid";

/*-------------*/

const purposeForDeleteAccount = [
  {"title": "I don't like the app"},
  {"title": "Found a better alternative app"},
  {"title": "I have another Presshop Account"},
  {"title": "No longer using the app"},
  {"title": "App is too complicated or hard to use"},
  {"title": "Technical issues (e.g., bugs, crashes)"},
  {"title": "Privacy or data concerns"},
  {"title": "Other"}
];

/*---CommonColors------*/
const colorThemePink = Color(0xFFEC4E54);
const colorHint = Color(0xFF9DA3A3);
const colorLightGrey = Color(0xFFF3F5F4);
const colorTextFieldBorder = Color(0xFF858585);
const colorTextFieldIcon = Color(0xFF505050);
const colorGoogleButtonBorder = Color(0xFF979797);
const colorSwitchBack = Color(0xFFD9D9D9);
const colorGreyNew = Color(0xFF656565);
const colorLightGreen = Color(0xFF3F4E4C);
const colorInactiveSlider = Color(0xFFECECEC);
const colorLightWhite = Color(0xFFF3F5F4);
const colorGrey1 = Color(0xFFB6CCC9);
const colorGrey2 = Color(0xFF7D8D8B);
const colorGrey3 = Color(0xFFAEB4B3);
const colorGrey4 = Color(0xFFDEDFDF);
const colorGrey5 = Color(0xFF313131);
const colorGrey6 = Color(0xFF4C4C4C);
const colorOnlineGreen = Color(0xFF16CE12);
const colorGreyChat = Color(0xFFCECECE);
const lightGrey = Color(0xFFD3DDDC);

/*--------End--------*/

/*-----------Common Numbers---------*/
const numD002 = 0.002;
const numD003 = 0.003;
const numD004 = 0.004;
const numD005 = 0.005;
const numD0055 = 0.0055;
const numD006 = 0.006;
const numD008 = 0.008;
const numD009 = 0.009;
const numD01 = 0.01;
const numD012 = 0.012;
const numD013 = 0.013;
const numD014 = 0.014;
const numD015 = 0.015;
const numD016 = 0.016;
const numD017 = 0.017;
const numD018 = 0.018;
const numD019 = 0.019;
const numD02 = 0.02;
const numD021 = 0.021;
const numD022 = 0.022;
const numD023 = 0.023;
const numD024 = 0.024;
const numD025 = 0.025;
const numD026 = 0.026;
const numD027 = 0.027;
const numD028 = 0.028;
const numD029 = 0.029;
const numD03 = 0.03;
const numD031 = 0.031;
const numD032 = 0.032;
const numD033 = 0.033;
const numD034 = 0.034;
const numD035 = 0.035;
const numD036 = 0.036;
const numD037 = 0.037;
const numD0375 = 0.0375;
const numD038 = 0.038;
const numD039 = 0.039;
const numD04 = 0.04;
const numD040 = 0.040;
const numD041 = 0.041;
const numD042 = 0.042;
const numD043 = 0.043;
const numD044 = 0.044;
const numD045 = 0.045;
const numD046 = 0.046;
const numD047 = 0.047;
const numD048 = 0.048;
const numD049 = 0.049;
const numD05 = 0.05;
const numD051 = 0.0511;
const numD052 = 0.052;
const numD053 = 0.053;
const numD054 = 0.054;
const numD055 = 0.055;
const numD056 = 0.056;
const numD0565 = 0.0565;
const numD0568 = 0.0568;
const numD057 = 0.057;
const numD0575 = 0.0575;
const numD058 = 0.058;
const numD0585 = 0.0585;
const numD059 = 0.059;
const numD06 = 0.06;
const numD065 = 0.065;
const numD07 = 0.07;
const numD072 = 0.072;
const numD075 = 0.075;
const numD08 = 0.08;
const numD081 = 0.081;
const numD082 = 0.082;
const numD083 = 0.083;
const numD084 = 0.084;
const numD085 = 0.085;
const numD09 = 0.09;
const numD10 = 0.10;
const numD095 = 0.095;
const numD1 = 0.1;
const numD11 = 0.11;
const numD12 = 0.12;
const numD13 = 0.13;
const numD14 = 0.14;
const numD15 = 0.15;
const numD16 = 0.16;
const numD17 = 0.17;
const numD18 = 0.18;
const numD19 = 0.19;
const numD20 = 0.20;
const numD21 = 0.21;
const numD22 = 0.22;
const numD23 = 0.23;
const numD24 = 0.24;
const numD25 = 0.25;
const numD26 = 0.26;
const numD27 = 0.27;
const numD28 = 0.28;
const numD29 = 0.29;
const numD30 = 0.30;
const numD31 = 0.31;
const numD32 = 0.32;
const numD33 = 0.33;
const numD34 = 0.34;
const numD35 = 0.35;
const numD36 = 0.36;
const numD37 = 0.37;
const numD38 = 0.38;
const numD39 = 0.39;
const numD40 = 0.40;
const numD44 = 0.44;
const numD45 = 0.45;
const numD47 = 0.47;
const numD48 = 0.48;
const numD50 = 0.50;
const numD51 = 0.51;
const numD52 = 0.52;
const numD53 = 0.53;
const numD54 = 0.54;
const numD55 = 0.55;
const numD60 = 0.60;
const numD65 = 0.65;
const numD70 = 0.70;
const numD80 = 0.80;
const numD90 = 0.90;

const num0 = 0.0;
const num1 = 1.0;
const num15 = 1.5;
const num16 = 1.6;
const num17 = 1.7;
const num18 = 1.8;
const num19 = 1.9;
const num2 = 2.0;
const num21 = 2.1;
const num22 = 2.2;
const num225 = 2.25;
const num23 = 2.3;
const num24 = 2.4;
const num25 = 2.5;
const num26 = 2.6;
const num27 = 2.7;
const num28 = 2.8;
const num29 = 2.9;
const num3 = 3.0;
const num31 = 3.1;
const num32 = 3.2;
const num33 = 3.3;
const num34 = 3.4;
const num35 = 3.5;
const num36 = 3.6;
const num37 = 3.7;
const num4 = 4.0;
const num5 = 5.0;
const num51 = 5.1;
const num52 = 5.2;
const num53 = 5.3;
const num54 = 5.4;
const num55 = 5.5;
const num56 = 5.6;
const num57 = 5.7;
const num58 = 5.8;
const num59 = 5.9;
const num6 = 6.0;
const num7 = 7.0;
const num8 = 8.0;
const num9 = 9.0;
const num10 = 10.0;

const numInt0 = 0;
const numInt1 = 1;
const numInt2 = 2;
const numInt3 = 3;
const numInt4 = 4;
const numInt5 = 5;
const numInt6 = 6;
const numInt7 = 7;
const numInt8 = 8;
const numInt9 = 9;
const numInt10 = 10;

const headerFontSize = 0.06;
const appBarHeadingFontSize = 0.045;
const appBarHeadingFontSizeNew = 0.05;
/*----------------------------------*/
const euroUniqueCode = "\u{000A3}";

String changeDateFormat(String inputFormat, String input, String outputFormat) {
  debugPrint("InpoutDate: $input");
  var inputDF = DateFormat(inputFormat);
  var inputDate = inputDF.parse(input, true);
  var outputDF = DateFormat(outputFormat);
  var outputDate = outputDF.format(inputDate);
  debugPrint("outputDate: $outputDate");
  return outputDate;
}

dynamic numberFormatting(dynamic number) {
  String value = number.toString();
  try {
    if (value.length == 1) {
      return int.parse(value);
    } else {
      double parseValue = double.parse(value);

      String decimalFormatting = parseValue
          .toStringAsFixed(parseValue.truncateToDouble() == parseValue ? 0 : 2);

      debugPrint("numberFormatting:::: $decimalFormatting");

      if (decimalFormatting.contains(".")) {
        return double.parse(decimalFormatting);
      } else {
        return double.parse(decimalFormatting);
      }
    }
  } on FormatException catch (e) {
    debugPrint("Number Exception============>$e");
    return 0;
  }
}

String dateTimeFormatter(
    {required String dateTime,
    String format = "d MMM yyyy",
    bool time = false,
    bool utc = false}) {
  debugPrint("dateTimeFormatter::::$dateTime");
  try {
    DateTime currentDateTime =
        utc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    DateTime parseDateTime = DateTime.now();

    if (dateTimeFormatCheck(dateTime) && format.isNotEmpty) {
      parseDateTime = DateTime.parse(dateTime);
    } else if (time) {
      String date = DateFormat('d MMMM yyyy').format(currentDateTime);
      parseDateTime = DateTime.parse("$date $dateTime");
    } else {
      String time = DateFormat('hh:mm a').format(currentDateTime);
      parseDateTime = DateTime.parse("$dateTime $time");
    }

    return DateFormat(format)
        .format(utc ? parseDateTime.toUtc() : parseDateTime.toLocal());
  } on FormatException catch (e) {
    debugPrint("$e");
    return DateFormat(format).format(DateTime.now());
  }
}

bool dateTimeFormatCheck(String date) {
  try {
    DateTime covertValue = DateTime.parse(date);
    return true;
  } on FormatException catch (e) {
    return false;
  }
}

/// Share
Future<void> shareLink(
    {required String title,
    required String description,
    required String taskName}) async {
  await Share.share("Please check out $taskName \n $title \n $description"
      "Post\n$appUrl");
}

///Time--format-->
String formatDuration(Duration d) {
  var seconds = d.inSeconds;
  final days = seconds ~/ Duration.secondsPerDay;
  seconds -= days * Duration.secondsPerDay;
  final hours = seconds ~/ Duration.secondsPerHour;
  seconds -= hours * Duration.secondsPerHour;
  final minutes = seconds ~/ Duration.secondsPerMinute;
  seconds -= minutes * Duration.secondsPerMinute;

  final List<String> tokens = [];
  if (days != 0) {
    tokens.add('${days}d ');
  }
  if (tokens.isNotEmpty || hours != 0) {
    tokens.add('${hours}h');
  }
  if (tokens.isNotEmpty || minutes != 0) {
    tokens.add('${minutes}m');
  }
  tokens.add('${seconds}s');

  return tokens.join(':');
}

bool isSixInchScreen(BuildContext context) {
  var mediaQuery = MediaQuery.of(context);

  double widthPx = mediaQuery.size.width * mediaQuery.devicePixelRatio;
  double heightPx = mediaQuery.size.height * mediaQuery.devicePixelRatio;
  double dpi = mediaQuery.devicePixelRatio * 160;

  // Calculate diagonal size in inches
  double diagonalSizeInches = sqrt(pow(widthPx, 2) + pow(heightPx, 2)) / dpi;

  return diagonalSizeInches >= 5.8 && diagonalSizeInches <= 6.2;
}

void showToast(String msg, [Toast toastLength = Toast.LENGTH_SHORT]) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: lightGrey,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

bool isKeyEmptyMap(Map<String, dynamic> data, String key) {
  if (data[key] == null) return true;
  return data[key] is Map && data[key].isEmpty;
}

bool get isIpad => sharedPreferences?.getBool("isIpad") ?? false;
