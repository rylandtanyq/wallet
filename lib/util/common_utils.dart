import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> userInfoSettingCache(Map userInfo) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String jsonStr = jsonEncode(userInfo);
  bool ret = await prefs.setString('userInfo', jsonStr);
  return ret;
}

Future<Map?> userInfoGettingCache() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userInfoStr = prefs.getString('userInfo');
  Map userInfoMap = {};
  if (userInfoStr != null) {
    userInfoMap = json.decode(userInfoStr);
  }
  return userInfoMap;
}
