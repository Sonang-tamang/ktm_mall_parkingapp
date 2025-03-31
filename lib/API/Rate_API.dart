import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BaseRateService {
  static const String _baseUrl =
      'https://novel-finch-neat.ngrok-free.app/api/changeBaseRate/';
  static Map<String, String> _headers(String token) => {
    'tenant': 'ranjana',
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>?> getBaseRates(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _headers(token),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        double? parseDouble(dynamic value) {
          if (value == null) return null;
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) {
            return double.tryParse(value);
          }
          return null;
        }

        final twoWheelerRate = parseDouble(data['two_wheeler_rate']) ?? 0.0;
        final fourWheelerRate = parseDouble(data['four_wheeler_rate']) ?? 0.0;

        print('Converted Two-Wheeler Rate: $twoWheelerRate');
        print('Converted Four-Wheeler Rate: $fourWheelerRate');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('two_wheeler_rate', twoWheelerRate);
        await prefs.setDouble('four_wheeler_rate', fourWheelerRate);

        return {
          'two_wheeler_rate': twoWheelerRate,
          'four_wheeler_rate': fourWheelerRate,
        };
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rates: $e');
      return null;
    }
  }

  static Future<bool> updateBaseRate(
    String token,
    double twoWheelerRate,
    double fourWheelerRate,
  ) async {
    try {
      final Map<String, dynamic> body = {
        'two_wheeler_rate': twoWheelerRate,
        'four_wheeler_rate': fourWheelerRate,
      };

      print('Sending request to $_baseUrl');
      print('Headers: ${_headers(token)}');
      print('Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers(token),
        body: json.encode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Update successful');
        return true;
      } else {
        throw Exception('Failed to update rate: ${response.body}');
      }
    } catch (e) {
      print('Error updating rate: $e');
      return false;
    }
  }
}
