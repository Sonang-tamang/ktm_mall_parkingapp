import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BaseRateService {
  static const String _baseUrl =
      'https://parking.goodwish.com.np/api/changeBaseRate/';
  static Map<String, String> _headers(String token) => {
        'tenant': 'ktm-mall.parking.goodwish.com.np',
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      };

  // Fetch the current rates

  static Future<Map<String, dynamic>?> getBaseRates(String token) async {
    try {
      final response =
          await http.get(Uri.parse(_baseUrl), headers: _headers(token));

      // Log the response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Convert string values to double
        final twoWheelerRate = double.parse(data['two_wheeler_rate']);
        final fourWheelerRate = double.parse(data['four_wheeler_rate']);
        final heavyVehicleRate = double.parse(data['heavy_vehicle_rate']);

        // Log converted values
        print('Converted Two-Wheeler Rate: $twoWheelerRate');
        print('Converted Four-Wheeler Rate: $fourWheelerRate');
        print('Converted Heavy Vehicle Rate: $heavyVehicleRate');

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save converted rates to SharedPreferences
        await prefs.setDouble('two_wheeler_rate', twoWheelerRate);
        await prefs.setDouble('four_wheeler_rate', fourWheelerRate);
        await prefs.setDouble('heavy_vehicle_rate', heavyVehicleRate);

        return {
          'two_wheeler_rate': twoWheelerRate,
          'four_wheeler_rate': fourWheelerRate,
          'heavy_vehicle_rate': heavyVehicleRate,
        };
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rates: $e');
      return null;
    }
  }

  // Update base rate
  static Future<bool> updateBaseRate(String token, double twoWheelerRate,
      double fourWheelerRate, double heavyVehicleRate, String passcode) async {
    try {
      final Map<String, dynamic> body = {
        'two_wheeler_rate': twoWheelerRate,
        'four_wheeler_rate': fourWheelerRate,
        'heavy_vehicle_rate': heavyVehicleRate,
        'passcode': passcode,
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
