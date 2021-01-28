import 'dart:convert';

import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://api.lkmng.com/';

  static var url = domain + 'url/index.php';
  static var merchant = domain + 'merchant/index.php';

  static callApi(url, Map<String, String> params) async {
    var response = await http.post(url, body: params);
    return jsonDecode(response.body);
  }
}
