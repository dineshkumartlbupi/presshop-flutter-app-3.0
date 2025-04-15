import 'package:shared_preferences/shared_preferences.dart';


/*----SharedPreference Common Keys-----*/
const headerKey ="Authorization";
const tokenKey = "token";
const hopperIdKey = "_id";
const profileImageKey = "profile_image";
const rememberKey = "remember";
const pinKey = "pinKey";
const lockTypeKey = "lock_type";
const lockSetKey = "lock_set";

const postCodeKey = "post_code";
const firstNameKey = "first_name";
const lastNameKey = "last_name";
const userNameKey = "user_name";
const emailKey = "email";
const phoneKey = "phone";
const dobKey = "dob";
const countryCodeKey = "country_code";
const roleKey = "role";
const addressKey = "address";
const passwordKey = "password";
const latitudeKey = "latitude";
const longitudeKey = "longitude";
const countryKey = "country";
const cityKey = "city";
const apartmentKey = "appartment";



const avatarKey = "avatar";
const avatarIdKey = "avatar_id";
const isTermAcceptedKey = "is_terms_accepted";
const receiveTaskNotificationKey = "recieve_task_notification";
const skipDocumentsKey = "skip_doc";
const file1Key = "file1";
const file2Key = "file2";
const file3Key = "file3";
const file1NameKey = "file1NameKey";
const file2NameKey = "file2NameKey";
const file3NameKey = "file3NameKey";

const adminIdKey = "adminIdKey";
const adminRoomIdKey = "adminRoomIdKey";
const adminImageKey = "adminImageKey";
const adminNameKey = "adminNameKey";

const currentLat = "currentLat";
const currentLon = "currentLat";
const currentAddress = "currentAddress";
const currentState = "currentLState";
const currentCountry = "currentCountry";
const currentCity = "currentCity";
/*------------------------------------*/

Future<SharedPreferences> getSharedPreferences() async {
  // Obtain shared preferences.
  var prefs = await SharedPreferences.getInstance();
  return prefs;
}

