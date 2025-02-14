import 'package:pakingapp/database/parkingdatabase.dart';

Future<void> checkIn({
  required String receiptId,
  required String vehicleNumber,
  required String vehicleType,
  required String checkinTime,
  required int checkedinBy,
}) async {
  final dbHelper = DatabaseHelper.instance;

  final existingRecord = await dbHelper.fetchByReceiptId(receiptId);
  if (existingRecord == null) {
    await dbHelper.insertData({
      'receipt_id': receiptId,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'checkin_time': checkinTime,
      'checkedin_by': checkedinBy,
    });
  } else {
    print('Vehicle already checked in.');
  }
}
