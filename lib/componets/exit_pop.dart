import 'package:flutter/material.dart';
import 'package:pakingapp/API/IN_out.dart';
import 'package:pakingapp/database/parkingdatabase.dart';
import 'package:pakingapp/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';

double crunnet_two_rate = 0;
double crunnet_four_rate = 0;
double crunnet_heavy_rate = 0;
String token = "";
int id = 0;
double? parkingFee;
VehicleService vehicleService = VehicleService();
String first_name = '';
String last_name = "";

String receiptId = '';
String vehicleNumber = '';
String vehicleType = '';
DateTime? checkinTime;
int checkedoutBy = 0;

double amount = parkingFee ?? 0.0;

class DetailsDialog extends StatefulWidget {
  final Map<String, dynamic> record;
  final VoidCallback onCancel;
  final VoidCallback onPrint;

  const DetailsDialog({
    Key? key,
    required this.record,
    required this.onCancel,
    required this.onPrint,
  }) : super(key: key);

  @override
  _DetailsDialogState createState() => _DetailsDialogState();
}

class _DetailsDialogState extends State<DetailsDialog> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch stored data
    double? storedTwoWheelerRate = prefs.getDouble('two_wheeler_rate');
    double? storedFourWheelerRate = prefs.getDouble('four_wheeler_rate');
    double? storedHeavyVehicleRate = prefs.getDouble('heavy_vehicle_rate');
    String? storedToken = prefs.getString('token');
    int? storedId = prefs.getInt('id') ?? 0;
    first_name = prefs.getString('first_name') ?? '';
    last_name = prefs.getString('last_name') ?? '';

    // Log the values (for debugging purposes)
    print('Stored Two-Wheeler Rate: $storedTwoWheelerRate');
    print('Stored Four-Wheeler Rate: $storedFourWheelerRate');
    print('Stored Heavy Vehicle Rate: $storedHeavyVehicleRate');
    print('Stored Token: $storedToken');
    print("Stored ID: $storedId");

    // Update the state to reflect changes
    setState(() {
      crunnet_two_rate = storedTwoWheelerRate ?? 0;
      crunnet_four_rate = storedFourWheelerRate ?? 0;
      crunnet_heavy_rate = storedHeavyVehicleRate ?? 0;
      token = storedToken ?? "";
      id = storedId;
    });
  }

  void printText() async {
    parkingFee = _calculateParkingFee();
    DateTime? CO = DateTime.now();

    receiptId = '${widget.record['receipt_id']}';
    vehicleNumber = '${widget.record['vehicle_number']}';
    vehicleType = '${widget.record['vehicle_type']}';
    checkinTime = DateTime.tryParse(widget.record['checkin_time'] ?? '');
    checkedoutBy = id;

    double amount = parkingFee ?? 0.0;

    await SunmiPrinter.printText(
      'Kathmandu-mall \nParking Slip',
      style: SunmiTextStyle(bold: true, fontSize: 40),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Vehicle Number: $vehicleNumber  \nVehicle Type: $vehicleType  \nReceipt ID: $receiptId \nCheck-out BY: $first_name $last_name \nCheck-in Time: $checkinTime \nCheck-out Time: ${CO}',
      style: SunmiTextStyle(bold: true, fontSize: 20),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Total fee: RS $amount',
      style: SunmiTextStyle(bold: true, fontSize: 40),
    );

    // await SunmiPrinter.printText(
    //     "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
    //     style: SunmiTextStyle(
    //       bold: true,
    //       fontSize: 30,
    //     ));

    await SunmiPrinter.lineWrap(100); // Jump 2 lines

    print("hello");
    checkVehicleStatus('$receiptId');

    // Local Database Update
    final dbHelper = DatabaseHelper.instance;

    try {
      // Fetch existing record by receipt ID
      final existingRecord = await dbHelper.fetchByReceiptId(receiptId);

      if (existingRecord != null) {
        if (existingRecord['checkout_time'] != null) {
          print('Vehicle has already checked out. Skipping update.');
        } else {
          // Update record with check-out details only if not already checked out
          await dbHelper.updateData(receiptId, {
            'vehicle_number': vehicleNumber,
            'vehicle_type': vehicleType,
            'checkout_time': CO.toIso8601String(),
            'checkedout_by': checkedoutBy,
            'amount': amount,
          });
          print('Check-out data updated locally!');
        }
      } else {
        print(
          'Error: No matching check-in record found for receipt ID: $receiptId',
        );
        return;
      }
    } catch (e) {
      print('Error updating check-out data locally: $e');
    }

    // Example API check-out call
    final checkOutResponse = await vehicleService.checkOut(
      receiptId: receiptId,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      checkinTime: checkinTime.toString(),
      checkedinBy: "$id",
      checkoutTime: "$CO",
      checkedoutBy: "$id",
      amount: amount,
      token: token, // Passing the dynamic token
    );

    print(" the time = ${checkinTime.toString()}");

    print(checkOutResponse);
  }

  void checkVehicleStatus(String receiptId) async {
    try {
      final isCheckedOut = await DatabaseHelper.instance.isVehicleCheckedOut(
        receiptId,
      );

      if (isCheckedOut) {
        print(
          'The vehicle with receipt ID $receiptId has already checked out.',
        );
      } else {
        print(
          'The vehicle with receipt ID $receiptId has not checked out yet.',
        );
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  // Function to calculate the parking fee
  double _calculateParkingFee() {
    final checkInTime = DateTime.tryParse(widget.record['checkin_time'] ?? '');
    final vehicleType = '${widget.record['vehicle_type']}';

    final now = DateTime.now();
    final duration = now.difference(checkInTime!).inMinutes; // Time in minutes
    int hours = duration ~/ 60;
    double remainingMinutes = duration % 60;

    print("Time: $hours hours and $remainingMinutes minutes.");

    // final rate = (vehicleType == 'Four') ? 80 : 25;
    double rate = 0;

    switch (vehicleType) {
      case 'TWO_WHEELER':
        if (duration <= 30) {
          rate = 15;
        } else if (duration <= 60) {
          rate = crunnet_two_rate;
        } else {
          double extraFee = ((remainingMinutes ~/ 15)) * 5;
          rate = crunnet_two_rate * hours + extraFee;
        }

        break;
      case 'FOUR_WHEELER':
        if (duration <= 30) {
          rate = 40;
        } else if (duration <= 60) {
          rate = crunnet_four_rate;
        } else {
          double extraFee = ((remainingMinutes ~/ 15)) * 15;
          rate = crunnet_four_rate * hours + extraFee;
        }
        break;
      case 'HEAVY_VEHICLE':
        if (duration <= 30) {
          rate = 50;
        } else if (duration <= 60) {
          rate = crunnet_heavy_rate;
        } else {
          double extraFee = ((remainingMinutes ~/ 15)) * 15;
          rate = crunnet_four_rate * hours + extraFee;
        }
        // rate = ((duration / 60).ceil()) * crunnet_heavy_rate.toDouble();
        break;
      default:
        rate = 0; // Default case in case the vehicle type is not recognized
        print("Unknown vehicle type");
        break;
    }
    print("The rate for $vehicleType is \$${rate}");

    return rate;
  }

  // // Function to calculate the parking fee
  // double _calculateParkingFee() {
  //     final checkInTime = DateTime.tryParse(widget.record['checkin_time'] ?? '');
  //     final vehicleType = '${widget.record['vehicle_type']}';

  //   final now = DateTime.now();
  //   final duration = now.difference(checkInTime!).inMinutes; // Time in minutes

  //   int hours = duration ~/ 60;
  //   double remainingMinutes = duration % 60;

  //   print("Time: $hours hours and $remainingMinutes minutes.");

  //   double fee = 0;

  //   if (vehicleType == 'TWO_WHEELER') {
  //     if (duration <= 30) {
  //       fee = 15;
  //     } else if (duration <= 60) {
  //       fee = crunnet_two_rate;
  //     } else {
  //       double extraFee = ((remainingMinutes ~/ 15)) * 5;
  //       fee = crunnet_two_rate * hours + extraFee;
  //     }
  //   } else if (vehicleType == 'FOUR_WHEELER') {
  //     if (duration <= 30) {
  //       fee = 40;
  //     } else if (duration <= 60) {
  //       fee = crunnet_four_rate;
  //     } else {
  //       double extraFee = ((remainingMinutes ~/ 15)) * 15;
  //       fee = crunnet_four_rate * hours + extraFee;
  //     }
  //   } else if (vehicleType == 'HEAVY_VEHICLE') {
  //     // Keeping the old logic for HEAVY_VEHICLE

  //     fee = ((duration / 60).ceil()) * crunnet_heavy_rate.toDouble();
  //   } else {
  //     print("Unknown vehicle type");
  //     throw ArgumentError('Invalid vehicle type!');
  //   }

  //   print("The parking fee for $vehicleType is: RS ${fee}");
  //   return fee;
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Details for Receipt ID: ${widget.record['receipt_id']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Number: ${widget.record['vehicle_number']}'),
          Text('Vehicle Type: ${widget.record['vehicle_type']}'),
          Text('Check-In: ${widget.record['checkin_time']}'),
          Text(
            'Check-Out: ${widget.record['checkout_time'] ?? 'Not Checked Out'}',
          ),
          Text('Amount: RS${widget.record['amount']}'),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: Text('Cancel')),
        TextButton(
          onPressed: () {
            if (widget.record['checkout_time'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('This vehicle has alreday checked out!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              printText();
              goto_Home();
            }
          },
          child: Text('Print'),
        ),
      ],
    );
  }

  void goto_Home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
    );
  }
}
