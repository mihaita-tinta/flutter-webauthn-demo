import 'dart:convert';

import 'package:flutter_app/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {

  static Future<User> get() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? u = prefs.getString('current_user');
    if (u == null) {
      return Future.error('No user logged in');
    }
    return User.fromJson(json.decode(u));
  }
  static Future<Object> delete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove('current_user');
  }

  static Future<User> save(User u) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(u));
    return u;
  }
  static Future<String> saveDisplayName(String u) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', u);
    return u;
  }

  static Future<String> getDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('display_name');
    return string ?? '';
  }
}
