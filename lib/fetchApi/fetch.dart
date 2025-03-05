import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> fetchUser() async {
  final response = await http.get(Uri.parse("http://localhost/api/api.php"));

  if (response.statusCode == 200) {
    List user = jsonDecode(response.body);
    print(user);
  } else {
    print("Erreur : ${response.statusCode}");
  }
}
