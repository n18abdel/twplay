import 'dart:convert';
import 'package:http/http.dart' as http;

class Twitch {
  static Future<Map> request(Map body) async {
    return jsonDecode((await http.post(Uri.parse("https://gql.twitch.tv/gql"),
            headers: {
              "Content-Type": "application/json",
              "Client-ID": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            },
            body: json.encode(body)))
        .body);
  }
}
