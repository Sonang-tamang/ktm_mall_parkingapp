// Future<bool> isVehicleCheckedOut(String receiptId) async {
//   final db = await instance.database;
//   final result = await db.query(
//     'ParkingData',
//     columns: ['checkout_time'],
//     where: 'receipt_id = ?',
//     whereArgs: [receiptId],
//   );

//   // If result is not empty, check if 'checkout_time' is null
//   if (result.isNotEmpty) {
//     final checkoutTime = result.first['checkout_time'];
//     return checkoutTime != null; // Return true if the vehicle has checked out
//   }

//   // If no record is found, the receipt_id is invalid
//   throw Exception('No record found for the given receipt_id: $receiptId');
// }
