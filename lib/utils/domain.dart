import 'dart:convert';

import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://api.lkmng.com/';

  static var url = domain + 'url/index.php';

  callApi() async {
    var response =
        await http.post(Domain.url, body: {'read': '1', 'merchant_id': '1'});
    return jsonDecode(response.body);
  }
}
