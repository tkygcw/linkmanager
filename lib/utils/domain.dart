import 'dart:convert';

import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://mylink.my/';
//  static var domain = 'https://api.lkmng.com/';

  static var register = domain + 'registration/index.php';
  static var url = domain + 'url/index.php';
  static var link = domain + 'link/index.php';
  static var iconPath = domain + 'link/icon/';
  static var merchant = domain + 'merchant/index.php';
  static var branch = domain + 'branch/index.php';
  static var report = domain + 'report/index.php';

  static callApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return jsonDecode(response.body);
  }
}
