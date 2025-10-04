import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth tokens
  Future<void> saveAccessToken(String token) async {
    await _prefs?.setString(AppConstants.keyAccessToken, token);
  }

  String? getAccessToken() {
    return _prefs?.getString(AppConstants.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(AppConstants.keyRefreshToken, token);
  }

  String? getRefreshToken() {
    return _prefs?.getString(AppConstants.keyRefreshToken);
  }

  // Partner info
  Future<void> savePartnerId(String partnerId) async {
    await _prefs?.setString(AppConstants.keyPartnerId, partnerId);
  }

  String? getPartnerId() {
    return _prefs?.getString(AppConstants.keyPartnerId);
  }

  Future<void> savePartnerPhone(String phone) async {
    await _prefs?.setString(AppConstants.keyPartnerPhone, phone);
  }

  String? getPartnerPhone() {
    return _prefs?.getString(AppConstants.keyPartnerPhone);
  }

  // Onboarding status
  Future<void> setOnboarded(bool value) async {
    await _prefs?.setBool(AppConstants.keyIsOnboarded, value);
  }

  bool isOnboarded() {
    return _prefs?.getBool(AppConstants.keyIsOnboarded) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return getAccessToken() != null && getPartnerId() != null;
  }
}
