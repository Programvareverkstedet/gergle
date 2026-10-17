import 'package:shared_preferences/shared_preferences.dart';

const String kLastServerUriKey = 'last_server_uri';

Future<String?> loadLastServerUri() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(kLastServerUriKey);
}

Future<void> saveLastServerUri(String uri) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(kLastServerUriKey, uri);
}
