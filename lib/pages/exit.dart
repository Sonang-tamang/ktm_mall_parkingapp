// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pakingapp/API/IN_out.dart';
import 'package:pakingapp/database/parkingdatabase.dart';
import 'package:pakingapp/homepage.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:senraise_printer/senraise_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sun_parking/componets/history.dart';
// import 'package:sun_parking/componets/history_manager.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class Exit extends StatefulWidget {
  const Exit({super.key});

  @override
  State<Exit> createState() => _ExitState();
}

class _ExitState extends State<Exit> {
  Barcode? result;
  Map<String, dynamic>? ticketData;
  double? parkingFee;
  VehicleService vehicleService = VehicleService();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? _newresult;

  String VN = "";
  String VT = "";
  String RID = "";
  DateTime? CT;
  DateTime? CO;
  String first_name = '';
  String last_name = "";

  double crunnet_two_rate = 0;
  double crunnet_four_rate = 0;
  double crunnet_heavy_rate = 0;
  int id = 0;
  String token = "";

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
    String? storedtoken = prefs.getString('token');
    int? storedid = prefs.getInt('id') ?? 0;
    first_name = prefs.getString('first_name') ?? '';
    last_name = prefs.getString('last_name') ?? '';

    // Log the values
    print('Stored Two-Wheeler Rate: $storedTwoWheelerRate');
    print('Stored Four-Wheeler Rate: $storedFourWheelerRate');
    print('Stored Heavy Vehicle Rate: $storedHeavyVehicleRate');
    print('Store token $storedtoken');
    print("srored id = $storedid");

    // Update the state to reflect changes
    //remove set state from here
    crunnet_two_rate = storedTwoWheelerRate ?? 0; // Default to 0 if not found
    crunnet_four_rate = storedFourWheelerRate ?? 0;
    crunnet_heavy_rate = storedHeavyVehicleRate ?? 0;
    token = storedtoken ?? "";
    id = storedid;
  }

  // Function to parse QR data
  Map<String, dynamic>? _parseQRCode(String data) {
    print(data);
    try {
      // Split the data by " ;" and trim each part
      final parts = data.split(' ;').map((part) => part.trim()).toList();

      if (parts.length < 4) {
        throw Exception("Invalid QR Code data format");
      }

      // Assign parts to respective variables
      final vehicleNumber = parts[0];
      final vehicleType = parts[1];
      final receiptID = parts[2];
      final checkInTime = DateTime.parse(parts[3]);

      return {
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
        'receiptID': receiptID,
        'checkInTime': checkInTime,
      };
    } catch (e) {
      print("Error parsing QR Code: $e");
      return null; // Return null if parsing fails
    }
  }

  // Function to calculate the parking fee
  // double _calculateParkingFee(Map<String, dynamic> data) {
  //   final checkInTime = data['checkInTime'] as DateTime;
  //   final vehicleType = data['vehicleType'] as String;

  //   final now = DateTime.now();
  //   final duration = now.difference(checkInTime).inMinutes; // Time in minutes
  //   final hours = (duration / 60).ceil(); // Round up to the nearest hour

  //   // final rate = (vehicleType == 'Four') ? 80 : 25;
  //   double rate = 0;

  //   switch (vehicleType) {
  //     case 'TWO_WHEELER':
  //       rate = crunnet_two_rate;
  //       break;
  //     case 'FOUR_WHEELER':
  //       rate = crunnet_four_rate;
  //       break;
  //     case 'HEAVY_VEHICLE':
  //       rate = crunnet_heavy_rate;
  //       break;
  //     default:
  //       rate = 0; // Default case in case the vehicle type is not recognized
  //       print("Unknown vehicle type");
  //       break;
  //   }
  //   print("The rate for $vehicleType is RS${rate}");

  //   return hours * rate.toDouble();
  // }

  // Function to calculate the parking fee
  double _calculateParkingFee(Map<String, dynamic> data) {
    final checkInTime = data['checkInTime'] as DateTime;
    final vehicleType = data['vehicleType'] as String;

    final now = DateTime.now();
    final duration = now.difference(checkInTime).inMinutes; // Time in minutes

    int hours = duration ~/ 60;
    double remainingMinutes = duration % 60;

    print("Time: $hours hours and $remainingMinutes minutes.");

    double fee = 0;

    if (vehicleType == 'TWO_WHEELER') {
      if (duration <= 30) {
        fee = 15;
      } else if (duration <= 60) {
        fee = crunnet_two_rate;
      } else {
        double extraFee = ((remainingMinutes ~/ 15)) * 5;
        fee = crunnet_two_rate * hours + extraFee;
      }
    } else if (vehicleType == 'FOUR_WHEELER') {
      if (duration <= 30) {
        fee = 40;
      } else if (duration <= 60) {
        fee = crunnet_four_rate;
      } else {
        double extraFee = ((remainingMinutes ~/ 15)) * 15;
        fee = crunnet_four_rate * hours + extraFee;
      }
    } else if (vehicleType == 'HEAVY_VEHICLE') {
      if (duration <= 30) {
        fee = 50;
      } else if (duration <= 60) {
        fee = crunnet_four_rate;
      } else {
        double extraFee = ((remainingMinutes ~/ 15)) * 15;
        fee = crunnet_heavy_rate * hours + extraFee;
      }

      // fee = ((duration / 60).ceil()) * crunnet_heavy_rate.toDouble();
    } else {
      print("Unknown vehicle type");
      throw ArgumentError('Invalid vehicle type!');
    }

    print("The parking fee for $vehicleType is: RS ${fee}");
    return fee;
  }

  void handleCheckout(
    Map<String, dynamic> ticketData,
    double calculatedPrice,
  ) async {
    try {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout successful! History updated.')),
      );

      // Perform additional actions if needed (like printing a bill)
    } catch (error) {
      // Handle duplicate Receipt ID or other errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  // void printtext() async {
  //   // Capture Check-out Details
  //   CO = DateTime.now(); // Current timestamp for check-out time
  //   String receiptId = ticketData?['receiptID'] ?? 'Unknown';
  //   String vehicleNumber = ticketData?['vehicleNumber'] ?? 'Unknown';
  //   String vehicleType = ticketData?['vehicleType'] ?? 'Unknown';
  //   DateTime? checkinTime = ticketData?['checkInTime'];
  //   int checkedoutBy = id; // ID of the user performing the check-out
  //   double amount = parkingFee ?? 0.0; // Total fee for parking

  //   ;

  //   await SunmiPrinter.printText('Kathmandu-mall \nParking Slip',
  //       style: SunmiTextStyle(
  //         bold: true,
  //         fontSize: 40,
  //       ));

  //   await SunmiPrinter.lineWrap(20);

  //   await SunmiPrinter.printText(
  //       'Vehicle Number: ${ticketData?['vehicleNumber'] ?? 'Unknown'} \nVehicle Type: ${ticketData?['vehicleType'] ?? 'Unknown'} \nReceipt ID: ${ticketData?['receiptID'] ?? 'Unknown'} \nCheck-out BY: $first_name $last_name \nCheck-in Time: ${ticketData?['checkInTime'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(ticketData!['checkInTime']) : 'Unknown'} \nCheck-out Time: ${CO}',
  //       style: SunmiTextStyle(
  //         bold: true,
  //         fontSize: 20,
  //       ));

  //   await SunmiPrinter.lineWrap(20);

  //   await SunmiPrinter.printText('Total fee: RS ${parkingFee}',
  //       style: SunmiTextStyle(
  //         bold: true,
  //         fontSize: 40,
  //       ));

  //   await SunmiPrinter.lineWrap(100); // Jump 2 lines

  //   print("hello");
  //   checkVehicleStatus('$receiptId');

  //   // Local Database Update
  //   final dbHelper = DatabaseHelper.instance;

  //   try {
  //     // Fetch existing record by receipt ID
  //     final existingRecord = await dbHelper.fetchByReceiptId(receiptId);

  //     if (existingRecord != null) {
  //       if (existingRecord['checkout_time'] != null) {
  //         print('Vehicle has already checked out. Skipping update.');
  //       } else {
  //         // Update record with check-out details only if not already checked out
  //         await dbHelper.updateData(receiptId, {
  //           'vehicle_number': vehicleNumber,
  //           'vehicle_type': vehicleType,
  //           'checkout_time': CO?.toIso8601String(),
  //           'checkedout_by': checkedoutBy,
  //           'amount': amount,
  //         });
  //         print('Check-out data updated locally!');
  //       }
  //     } else {
  //       print(
  //           'Error: No matching check-in record found for receipt ID: $receiptId. Inserting new record.');
  //       return;
  //     }
  //   } catch (e) {
  //     print('Error updating check-out data locally: $e');
  //   }

  //   // Example API check-out call
  //   final checkOutResponse = await vehicleService.checkOut(
  //     receiptId: "${ticketData?['receiptID'] ?? 'Unknown'}",
  //     vehicleNumber: "${ticketData?['vehicleNumber'] ?? 'Unknown'}",
  //     vehicleType: "${ticketData?['vehicleType'] ?? 'Unknown'}",
  //     checkinTime:
  //         "${ticketData?['checkInTime'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(ticketData!['checkInTime']) : 'Unknown'}",
  //     checkedinBy: "$id",
  //     checkoutTime: "$CO",
  //     checkedoutBy: "$id",
  //     amount: amount,
  //     token: token, // Passing the dynamic token
  //   );

  //   print(checkOutResponse);
  // }

  void printtext() async {
    print("heloo print");
    // Capture Check-out Details
    CO = DateTime.now(); // Current timestamp for check-out time
    String receiptId = ticketData?['receiptID'] ?? 'Unknown';
    String vehicleNumber = ticketData?['vehicleNumber'] ?? 'Unknown';
    String vehicleType = ticketData?['vehicleType'] ?? 'Unknown';
    DateTime? checkinTime = ticketData?['checkInTime'];
    int checkedoutBy = id; // ID of the user performing the check-out
    double amount = parkingFee ?? 0.0; // Total fee for parking

    // Printing
    await SunmiPrinter.printText(
      'Kathmandu-mall \nParking Slip',
      style: SunmiTextStyle(bold: true, fontSize: 40),
    );
    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Vehicle Number: $vehicleNumber \nVehicle Type: $vehicleType \nReceipt ID: $receiptId \nCheck-out BY: $first_name $last_name \nCheck-in Time: ${checkinTime != null ? DateFormat('yyyy-MM-dd HH:mm').format(checkinTime) : 'Unknown'} \nCheck-out Time: $CO',
      style: SunmiTextStyle(bold: true, fontSize: 20),
    );
    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Total fee: RS $amount',
      style: SunmiTextStyle(bold: true, fontSize: 40),
    );
    await SunmiPrinter.lineWrap(100); // Jump 2 lines

    print("Printing complete!");
    checkVehicleStatus(receiptId);

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
            'checkout_time': CO?.toIso8601String(),
            'checkedout_by': checkedoutBy,
            'amount': amount,
          });
          print('Check-out data updated locally!');
        }
      } else {
        // Insert a new record if no matching check-in record is found
        print(
          'No matching check-in record found for receipt ID: $receiptId. Inserting new record.',
        );

        await dbHelper.insertData({
          'receipt_id': receiptId,
          'vehicle_number': vehicleNumber,
          'vehicle_type': vehicleType,
          'checkin_time': CO?.toIso8601String(),
          'checkout_time': CO?.toIso8601String(),
          'amount': amount,
          'checkedin_by': checkedoutBy,
          'checkedout_by': checkedoutBy,
        });

        print('New check-out record inserted locally!');
      }
    } catch (e) {
      print('Error handling database operation: $e');
    }

    // Example API check-out call
    final checkOutResponse = await vehicleService.checkOut(
      receiptId: receiptId,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      checkinTime:
          checkinTime != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(checkinTime)
              : 'Unknown',
      checkedinBy: "$id",
      checkoutTime: "$CO",
      checkedoutBy: "$id",
      amount: amount,
      token: token, // Passing the dynamic token
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exit Parking"),
        actions: [
          Padding(
            padding: EdgeInsets.all(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () async {
                await controller?.toggleFlash();
                setState(() {}); // Update the UI after toggling the flash
              },
              child: FutureBuilder(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  bool isFlashOn =
                      snapshot.data ??
                      false; // Default to false if snapshot.data is null
                  return Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isFlashOn
                            ? Icons.flashlight_off_rounded
                            : Icons.flashlight_on_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(flex: 4, child: _buildQrView(context)),

            // SizedBox(
            //   height: 300,
            //   width: 350,
            //   child: _buildQrView(context),
            // ),
            SizedBox(height: 10),

            // Display scanned data
            Expanded(
              flex: 3,
              child:
                  result != null
                      ? ticketData != null
                          ? Card(
                            margin: const EdgeInsets.all(16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Vehicle Number: ${ticketData?['vehicleNumber'] ?? 'Unknown'}",
                                  ),
                                  Text(
                                    "Vehicle Type: ${ticketData?['vehicleType'] ?? 'Unknown'}",
                                  ),
                                  Text(
                                    "Receipt ID: ${ticketData?['receiptID'] ?? 'Unknown'}",
                                  ),
                                  Text(
                                    "Check-in Time: ${ticketData?['checkInTime'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(ticketData!['checkInTime']) : 'Unknown'}",
                                  ),
                                  SizedBox(height: 8.0),
                                  Divider(),
                                  Text(
                                    "Total Fee: Rs. ${parkingFee?.toStringAsFixed(2) ?? '0.00'}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : Text("Invalid QR Code", textAlign: TextAlign.center)
                      : Text(
                        "Scan a QR Code to retrieve details",
                        textAlign: TextAlign.center,
                      ),
            ),
            // Buttons to clear or save history
            if (result != null)
              Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: 200,
                    child: GestureDetector(
                      // onTap: () {
                      //   if (ticketData != null && parkingFee != null) {
                      //     handleCheckout(ticketData!, parkingFee!);
                      //     printtext();
                      //   } else {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(
                      //           content: Text(
                      //               'Invalid data! Please scan a valid QR.')),
                      //     );
                      //   }

                      //   goto_Home();
                      // },
                      onTap: () async {
                        if (ticketData != null && parkingFee != null) {
                          final isCheckedOut = await DatabaseHelper.instance
                              .isVehicleCheckedOut(ticketData!['receiptID']);
                          if (isCheckedOut) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Vehicle has already checked out!.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            print("heloo print");
                            handleCheckout(ticketData!, parkingFee!);
                            printtext();
                            goto_Home();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Invalid data! Please scan a valid QR.',
                              ),
                            ),
                          );
                        }
                      },
                      // onTap: () {
                      //   print("god ${ticketData!['receiptID']}");
                      //   printtext();
                      // },
                      child: Card(
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            "Print",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void goto_Home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
    );
  }

  // for barcode######################################

  Widget _buildQrView(BuildContext context) {
    var scanArea = 270.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        // _newresult = result!.code;

        if (result != null) {
          _newresult = result!.code;
          ticketData = _parseQRCode(_newresult!);
          if (ticketData != null) {
            parkingFee = _calculateParkingFee(ticketData!);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
