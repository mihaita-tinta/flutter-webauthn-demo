import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {

  static Future<String> get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? u = prefs.getString('token');
    if (u == null) {
      return Future.error('No token found');
    }
    return u;
  }

  static Future<String> save(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', value);
    return value;
  }
}
