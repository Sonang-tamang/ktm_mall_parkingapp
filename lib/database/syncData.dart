import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pakingapp/database/parkingdatabase.dart';

Future<void> syncDataToBackend() async {
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;

  final unsyncedData = await db.query(
    'ParkingData',
  ); // Get all records (filter unsynced if needed)

  for (final data in unsyncedData) {
    final response = await http.post(
      Uri.parse('https://your-backend-api.com/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Data synced successfully');
    } else {
      print('Failed to sync data: ${response.statusCode}');
    }
  }
}
