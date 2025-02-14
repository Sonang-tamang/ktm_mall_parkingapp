import 'package:pakingapp/database/parkingdatabase.dart';

Future<void> checkOut({
  required String receiptId,
  required String checkoutTime,
  required int checkedoutBy,
  required double amount,
}) async {
  final dbHelper = DatabaseHelper.instance;

  final existingRecord = await dbHelper.fetchByReceiptId(receiptId);
  if (existingRecord != null && existingRecord['checkout_time'] == null) {
    await dbHelper.updateData(receiptId, {
      'checkout_time': checkoutTime,
      'checkedout_by': checkedoutBy,
      'amount': amount,
    });
  } else {
    print('Vehicle already checked out or not found.');
  }
}
