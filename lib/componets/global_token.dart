import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static String Mytoken = "";

  Future Loadtoken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Mytoken = prefs.getString('token') ?? '';

    givetoken();
  }

  givetoken() {
    return Mytoken;
  }
}
