// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pakingapp/API/IN_out.dart';
import 'package:pakingapp/API/Rate_API.dart';
import 'package:pakingapp/API/api.dart';
import 'package:pakingapp/authentication/Login.dart';
import 'package:pakingapp/componets/Ticket_model.dart';
import 'package:pakingapp/componets/myDrawer.dart';
import 'package:pakingapp/database/parkingdatabase.dart';
import 'package:pakingapp/pages/exit.dart';
import 'package:senraise_printer/senraise_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _senraisePrinterPlugin = SenraisePrinter();
  final TextEditingController _VController = TextEditingController();
  final ApiService API = ApiService();
  VehicleService vehicleService = VehicleService();

  String VehicleType = "";
  String VN = "";
  String VT = "";
  String RID = "";
  DateTime? CT;

  // user details to Store
  String token = "";
  String username = "";
  String email = "";
  int id = 0;
  String first_name = '';
  String last_name = "";
  String phone = "";
  String address = "";
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      token = prefs.getString('token') ?? '';
      email = prefs.getString('email') ?? "";
      id = prefs.getInt('id') ?? 0;
      first_name = prefs.getString('first_name') ?? '';
      last_name = prefs.getString('last_name') ?? '';
      phone = prefs.getString('phone') ?? '';
      address = prefs.getString('address') ?? '';
      role = prefs.getString('role') ?? '';
    });
    fetchRates();
  }

  void fetchRates() async {
    var rates = await BaseRateService.getBaseRates(token);
    if (rates != null) {
      print('Two-wheeler rate: ${rates['two_wheeler_rate']}');
      print('Four-wheeler rate: ${rates['four_wheeler_rate']}');
      print('Heavy vehicle rate: ${rates['heavy_vehicle_rate']}');
    } else {
      print('Failed to fetch rates');
    }
  }

  void _showprofile(String tabName, String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$tabName"),
          content: Text("Email: $email\n\nAre you sure you want to logout"),
          actions: <Widget>[
            TextButton(
              child: Text("LOGOUT", style: TextStyle(color: Colors.red)),
              onPressed: () {
                API.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Vehicle Number"),
          content: TextField(
            controller: _VController,
            decoration: InputDecoration(hintText: "Type something..."),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_VController.text.isNotEmpty) {
                  printtext();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('NO Vehicle Number!!')),
                  );
                }
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Print"),
            ),
          ],
        );
      },
    );
  }

  void printtext() async {
    VN = _VController.text;
    VT = VehicleType;
    RID = Ticket.generateReceiptID();
    String CT = DateTime.now().toIso8601String();

    // Check vehicle type for specific formatting
    if (VehicleType == "CINEMA_BIKE") {
      await SunmiPrinter.printText(
        'Ranjana Trade Center \nParking Slip \nGrand Machhapuchehhre Technology',
        style: SunmiTextStyle(bold: true, fontSize: 35),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        'Vehicle Number: $VN  \nVehicle Type: $VT \nReceipt ID: $RID \nCheck-in BY: $first_name $last_name \nCheck-in Time: $CT \nPrice: Rs.50',
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printQRCode(
        '$VN ; $VT ;$RID ;$CT',
        style: SunmiQrcodeStyle(
          align: SunmiPrintAlign.CENTER,
          qrcodeSize: 4, // Reduced from 8 to 4 for smaller QR
          errorLevel: SunmiQrcodeLevel.LEVEL_Q,
        ),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(140);
    } else if (VehicleType == "CINEMA_CAR") {
      await SunmiPrinter.printText(
        'Ranjana Trade Center \nParking Slip \nGrand Machhapuchehhre Technology',
        style: SunmiTextStyle(bold: true, fontSize: 35),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        'Vehicle Number: $VN  \nVehicle Type: $VT \nReceipt ID: $RID \nCheck-in BY: $first_name $last_name \nCheck-in Time: $CT \nPrice: Rs.100',
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printQRCode(
        '$VN ; $VT ;$RID ;$CT',
        style: SunmiQrcodeStyle(
          align: SunmiPrintAlign.CENTER,
          qrcodeSize: 4, // Reduced from 8 to 4 for smaller QR
          errorLevel: SunmiQrcodeLevel.LEVEL_Q,
        ),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(140);
    } else {
      // Original printing logic for other vehicle types
      await SunmiPrinter.printText(
        'Ranjana Trade Center \nParking Slip \nGrand Machhapuchehhre Technology',
        style: SunmiTextStyle(bold: true, fontSize: 35),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        'Vehicle Number: $VN  \nVehicle Type: $VT \nReceipt ID: $RID \nCheck-in BY: $first_name $last_name \nCheck-in Time: $CT',
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printQRCode(
        '$VN ; $VT ;$RID ;$CT',
        style: SunmiQrcodeStyle(
          align: SunmiPrintAlign.CENTER,
          qrcodeSize: 4, // Reduced from 8 to 4 for smaller QR
          errorLevel: SunmiQrcodeLevel.LEVEL_Q,
        ),
      );

      await SunmiPrinter.lineWrap(20);

      await SunmiPrinter.printText(
        "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
        style: SunmiTextStyle(bold: true, fontSize: 25),
      );

      await SunmiPrinter.lineWrap(140);
    }

    // Save check-in data locally in SQLite
    final dbHelper = DatabaseHelper.instance;

    // Insert data into SQLite database
    try {
      final existingRecord = await dbHelper.fetchByReceiptId(RID);

      if (existingRecord == null) {
        await dbHelper.insertData({
          'receipt_id': RID,
          'vehicle_number': VN,
          'vehicle_type': VT,
          'checkin_time': CT,
          'checkedin_by': id,
        });
        print('Check-in data saved locally!');
      } else {
        print('Vehicle already checked in with this receipt ID.');
      }
    } catch (e) {
      print('Error saving check-in data locally: $e');
    }

    // For Check-in this for API
    final checkInResponse = await vehicleService.checkIn(
      receiptId: "$RID",
      vehicleNumber: "$VN",
      vehicleType: "$VT",
      checkinTime: "$CT",
      checkedinBy: "$id",
      token: token,
    );

    print(checkInResponse);
  }

  void printAllDayText(
    String vehicleType,
    String price, {
    String parkingType = "",
  }) async {
    String RID = Ticket.generateReceiptID();
    String CT = DateTime.now().toIso8601String();

    await SunmiPrinter.printText(
      'Ranjana Trade Center \nParking Slip \nGrand Machhapuchehhre Technology',
      style: SunmiTextStyle(bold: true, fontSize: 35),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Vehicle Number: ---  \nVehicle Type: $vehicleType${parkingType.isNotEmpty ? " ($parkingType)" : ""} \nReceipt ID: $RID \nCheck-in BY: $first_name $last_name \nCheck-in Time: $CT \nPrice: $price',
      style: SunmiTextStyle(bold: true, fontSize: 25),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printQRCode(
      '--- ; $vehicleType${parkingType.isNotEmpty ? " ($parkingType)" : ""} ;$RID ;$CT',
      style: SunmiQrcodeStyle(
        align: SunmiPrintAlign.CENTER,
        qrcodeSize: 4, // Reduced from 8 to 4 for smaller QR
        errorLevel: SunmiQrcodeLevel.LEVEL_Q,
      ),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
      style: SunmiTextStyle(bold: true, fontSize: 25),
    );

    await SunmiPrinter.lineWrap(140);

    // Save check-in data locally in SQLite
    final dbHelper = DatabaseHelper.instance;

    try {
      final existingRecord = await dbHelper.fetchByReceiptId(RID);

      if (existingRecord == null) {
        await dbHelper.insertData({
          'receipt_id': RID,
          'vehicle_number': '---',
          'vehicle_type':
              '$vehicleType${parkingType.isNotEmpty ? " ($parkingType)" : ""}',
          'checkin_time': CT,
          'checkedin_by': id,
        });
        print('Check-in data saved locally!');
      } else {
        print('Vehicle already checked in with this receipt ID.');
      }
    } catch (e) {
      print('Error saving check-in data locally: $e');
    }

    // For Check-in this for API
    final checkInResponse = await vehicleService.checkIn(
      receiptId: "$RID",
      vehicleNumber: "---",
      vehicleType:
          '$vehicleType${parkingType.isNotEmpty ? " ($parkingType)" : ""}',
      checkinTime: "$CT",
      checkedinBy: "$id",
      token: token,
    );

    print(checkInResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Parking app"),
        backgroundColor: const Color.fromARGB(255, 195, 188, 188),
        toolbarHeight: 80,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    _showprofile(" $first_name $last_name", "$email");
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage("assets/user.jpg"),
                    onBackgroundImageError: (_, __) => const Icon(Icons.error),
                  ),
                ),
                Text("$first_name $last_name"),
              ],
            ),
          ),
        ],
      ),
      drawer: Mydrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "Vehicle Type",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            VehicleType = "TWO_WHEELER";
                          });
                          _showPopup(context);
                        },
                        child: Card(
                          elevation: 20,
                          color: Colors.white,
                          child: Image.asset("assets/bike.jpg"),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            VehicleType = "FOUR_WHEELER";
                          });
                          _showPopup(context);
                        },
                        child: Card(
                          elevation: 20,
                          color: Colors.white,
                          child: Image.asset("assets/car.jpg"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Cinema Bike and Cinema Car buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            VehicleType = "CINEMA_BIKE";
                          });
                          _showPopup(context);
                        },
                        child: Card(
                          elevation: 15,
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              "Cinema Bike",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            VehicleType = "CINEMA_CAR";
                          });
                          _showPopup(context);
                        },
                        child: Card(
                          elevation: 15,
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              "Cinema Car",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // All Day Bike and All Day Car buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          printAllDayText("ALL_DAY_BIKE", "Rs.150");
                        },
                        child: Card(
                          elevation: 15,
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              "All Day Bike",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: 160,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Select Parking Type"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        printAllDayText(
                                          "ALL_DAY_CAR",
                                          "Rs.350",
                                          parkingType: "Inhouse",
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Inhouse"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        printAllDayText(
                                          "ALL_DAY_CAR",
                                          "Rs.400",
                                          parkingType: "Outsider",
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Outsider"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          elevation: 15,
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              "All Day Car",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // exit point
                GestureDetector(
                  onTap: () {
                    goto_exit();
                  },
                  child: SizedBox(
                    height: 100,
                    width: 200,
                    child: Card(
                      elevation: 15,
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          "Check Out",
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
          ),
        ),
      ),
    );
  }

  void goto_exit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Exit()));
  }
}
