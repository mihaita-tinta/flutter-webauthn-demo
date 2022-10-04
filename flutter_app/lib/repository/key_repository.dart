import 'package:shared_preferences/shared_preferences.dart';

class KeyRepository {
  static const String KEY_HANDLE_KEY = 'KEY_HANDLE';
  static const String USER_HANDLE_KEY = 'USER_HANDLE';

  static Future<String> loadKeyHandle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('${KeyRepository.KEY_HANDLE_KEY}') ?? '';
    return key;
  }
  static Future<String> loadUserHandle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = prefs.getString('${KeyRepository.USER_HANDLE_KEY}') ?? '';
    return key;
  }

  static Future<void> storeKeyHandle(String keyHandle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KeyRepository.KEY_HANDLE_KEY, keyHandle);
  }
  static Future<void> storeUserHandle(String keyHandle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(KeyRepository.USER_HANDLE_KEY, keyHandle);
  }

  static void removeAllKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys().forEach((key) => prefs.remove(key));
  }
}
