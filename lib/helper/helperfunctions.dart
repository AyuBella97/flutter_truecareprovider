import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{  
  static bool defaultEnterIsSend = false;
  static bool? enterIsSend;

  static bool defaultisActive = false;
  static bool? isActive;
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserId = "USERID";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceNameKey = "NAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
  static String sharedPreferenceUserImageKey = "USERIMAGEKEY";
  static String sharedPreferenceUserDeviceToken = "DEVICETOKEN";
  static String sharedPreferenceUserPhoneNo = "USERPHONEKEY";
  static String sharedPreferenceisStaff = "ISSTAFF";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  // user ID
  static Future<bool> saveUserIdSharedPreference(id) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserId, id);
  }

  static Future<String?> getUserIdSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserId);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveNameSharedPreference(String userFullName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceNameKey, userFullName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  }
  
  static Future<bool> saveImageSharedPreference(String userImage) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserImageKey, userImage);
  }

  static Future<bool> saveUserDeviceTokenPreference(String userDeviceToken) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserDeviceToken, userDeviceToken);
  }
  /// fetching data from sharedpreference

  static Future<bool?> getUserLoggedInSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getUserNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserNameKey);
  }

  static Future<String?> getUserEmailSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserEmailKey);
  }

  static Future<String?> getNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceNameKey);
  }

  static Future<String?> getImageSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserImageKey);
  }

  static Future<String?> getUserDeviceTokenPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserDeviceToken);
  }

  // phone
  static Future<bool> saveUserPhoneNoPreference(String userPhoneNo) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserPhoneNo, userPhoneNo);
  }

  static Future<String?> getUserPhoneNoPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceUserPhoneNo);
  }
  // phone

  static Future<bool> saveUserisStaff(String isStaff) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceisStaff, isStaff);
  }

  static Future<String?> getsaveUserisStaff() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(sharedPreferenceisStaff);
  }
  

  Future<bool> deleteAll() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.clear();
  }

}