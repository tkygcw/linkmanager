import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharePreferences {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(key);
    if (data != null) return json.decode(prefs.getString(key));
    else return null;
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
