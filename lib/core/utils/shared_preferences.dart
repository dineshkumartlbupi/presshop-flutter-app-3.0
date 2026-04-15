import 'package:shared_preferences/shared_preferences.dart';

/*----SharedPreference Common Keys-----*/

class SharedPreferencesKeys {
  static const headerKey = "Authorization";
  static const refreshHeaderKey = "x-refresh-token";
  static const accessHeaderKey = "x-access-token";

  static const headerDeviceTypeKey = "X-Device-Type";
  static const headerDeviceIdKey = "X-Device-ID";
  static const deviceIdKey = "device_id";
  static const tokenKey = "token";
  static const refreshtokenKey = "refreshToken";
  static const hopperIdKey = "_id";
  static const profileImageKey = "profile_image";
  static const rememberKey = "remember";
  static const pinKey = "pinKey";
  static const lockTypeKey = "lock_type";
  static const lockSetKey = "lock_set";

  static const postCodeKey = "post_code";
  static const firstNameKey = "first_name";
  static const referralCode = "referral_code";
  static const currencySymbolKey = "preferred_currency_sign";
  static const totalHopperArmy = "totalHopperArmy";
  static const videoLimitKey = "videoLimit";
  static const referralFriendEarningKey = "referral_friend_earning_amount";
  static const referralUserEarningKey = "referral_user_earning_amount";
  static const referralCurrencyKey = "referral_currency_symbol";

  static const lastNameKey = "last_name";
  static const userNameKey = "user_name";
  static const emailKey = "email";
  static const referredCodeKey = "referredCode";
  static const phoneKey = "phone";
  static const dobKey = "dob";
  static const countryCodeKey = "country_code";
  static const roleKey = "role";
  static const addressKey = "address";
  static const passwordKey = "password";
  static const latitudeKey = "latitude";
  static const longitudeKey = "longitude";
  static const countryKey = "country";
  static const cityKey = "city";
  static const apartmentKey = "appartment";

  static const avatarKey = "avatar";
  static const avatarIdKey = "avatar_id";
  static const isTermAcceptedKey = "is_terms_accepted";
  static const receiveTaskNotificationKey = "receive_task_notification";
  static const skipDocumentsKey = "skip_doc";
  static const file1Key = "file1";
  static const file2Key = "file2";
  static const file3Key = "file3";
  static const file1NameKey = "file1NameKey";
  static const file2NameKey = "file2NameKey";
  static const file3NameKey = "file3NameKey";
  static const totalIncomeKey = "totalEarnings";

  static const adminIdKey = "adminIdKey";
  static const adminRoomIdKey = "adminRoomIdKey";
  static const adminImageKey = "adminImageKey";
  static const adminNameKey = "adminNameKey";

  static const currentLat = "currentLat";
  static const currentLon = "currentLong";
  static const currentAddress = "currentAddress";
  static const currentState = "currentLState";
  static const currentCountry = "currentCountry";
  static const currentCity = "currentCity";
  static const contryCode = "contryCode";

  static const sourceDataIsOpenedKey = "sourceDataIsOpened";
  static const sourceDataTypeKey = "sourceDataType";
  static const sourceDataUrlKey = "sourceDataUrl";
  static const sourceDataHeadingKey = "sourceDataHeading";
  static const sourceDataDescriptionKey = "sourceDataDescription";
  static const sourceDataIsClickKey = "isClick";
  static const isCustomLocationPopupKey = "is_custom_location_popup";
  static const customLocationHeadingKey = "custom_location_heading";
  static const customLocationDescriptionKey = "custom_location_description";
  static const customPopupImageKey = "custom_popup_image";
  static const locationSharingDescriptionKey = "location_sharing_description";
  static const manuallyStoppedServiceKey = "manually_stopped_service";
  static const isTaskGrabbingActiveKey = "is_task_grabbing_active";
  static const alertInfoPopupShownKey = "alert_info_popup_shown";

  // Caching Keys
  static const tutorialCategoriesCacheKey = "tutorial_categories_cache";
  static const tutorialVideosCachePrefix = "tutorial_videos_cache_";
  static const faqCategoriesCacheKey = "faq_categories_cache_";
  static const faqItemsCachePrefix = "faq_items_cache_";
  static const termsCachePrefix = "terms_cache_";
}
/*------------------------------------*/

Future<SharedPreferences> getSharedPreferences() async {
  // Obtain shared preferences.
  var prefs = await SharedPreferences.getInstance();
  return prefs;
}
