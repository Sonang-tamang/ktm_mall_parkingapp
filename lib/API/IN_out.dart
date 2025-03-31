import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleService {
  static const String baseUrl = "https://novel-finch-neat.ngrok-free.app/api/";

  // Headers for the API requests
  Map<String, String> headers(String token) {
    return {
      "tenant": "ranjana",
      "Authorization": "Token $token",
      "Content-Type": "application/json",
    };
  }

  // Check-in method
  Future<Map<String, dynamic>> checkIn({
    required String receiptId,
    required String vehicleNumber,
    required String vehicleType,
    required String checkinTime,
    required String checkedinBy,
    required String token, // Token parameter
  }) async {
    final url = Uri.parse(baseUrl + 'checkin/');
    final body = json.encode({
      'receipt_id': receiptId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'checkin_time': checkinTime,
      'checkedin_by': checkedinBy,
    });

    try {
      final response = await http.post(
        url,
        headers: headers(token),
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check-in successful (handling both 200 and 201 responses)
        return json.decode(response.body);
      } else {
        // Handle error
        return {
          'error': 'Failed to check in',
          'status_code': response.statusCode,
          'response_body': response.body,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Check-out method
  Future<Map<String, dynamic>> checkOut({
    required String receiptId,
    required String vehicleNumber,
    required String vehicleType,
    required String checkinTime,
    required String checkedinBy,
    required String checkoutTime,
    required String checkedoutBy,
    required double amount,
    required String token, // Token parameter
  }) async {
    final url = Uri.parse(baseUrl + 'checkout/');
    final body = json.encode({
      'receipt_id': receiptId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'checkin_time': checkinTime,
      'checkedin_by': checkedinBy,
      'checkout_time': checkoutTime,
      'checkedout_by': checkedoutBy,
      'amount': amount,
    });

    try {
      final response = await http.post(
        url,
        headers: headers(token),
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Check-out successful
        return json.decode(response.body);
      } else {
        // Handle error
        return {
          'error': 'Failed to check out',
          'status_code': response.statusCode,
          'response_body': response.body,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
