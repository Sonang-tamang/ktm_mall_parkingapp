import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://parking.goodwish.com.np/api';

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/login/');
    final headers = {
      'tenant': 'ktm-mall.parking.goodwish.com.np',
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens for future use
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        // await prefs.setString('refresh_token', data['refresh']);
        await prefs.setBool('is_superadmin', data['is_superadmin']);
        await prefs.setString('username', data['user']['username']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setInt('id', data['user']['id']);
        await prefs.setString('first_name', data['user']['first_name']);
        await prefs.setString('last_name', data['user']['last_name']);
        await prefs.setString('phone', data['user']['phone']);
        await prefs.setString('address', data['user']['address']);
        await prefs.setString('role', data['user']['role']);

        return data; // Return user data for further processing
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
