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

  // user details to Storre
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

  // void chekin() {
  //   // For Check-in
  //   vehicleService
  //       .checkIn(
  //     receiptId: "12345",
  //     vehicleNumber: "ABC-1234",
  //     vehicleType: "Car",
  //     checkinTime: "2025-01-22T10:00:00",
  //     checkedinBy: "User",
  //   )
  //       .then((response) {
  //     print(response);
  //   });
  // }

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
    // final TextEditingController _VController = TextEditingController();

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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('NO Vehicl Number!!')));
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

    await SunmiPrinter.printText(
      'Kathmandu-mall \nParking Slip',
      style: SunmiTextStyle(bold: true, fontSize: 40),
    );

    await SunmiPrinter.lineWrap(20);

    await SunmiPrinter.printText(
      'Vehicle Number: $VN  \nVehicle Type: $VT \nReceipt ID: $RID \nCheck-in BY: $first_name $last_name \nCheck-in Time: $CT',
      style: SunmiTextStyle(bold: true, fontSize: 30),
    );

    await SunmiPrinter.lineWrap(30);

    await SunmiPrinter.printQRCode(
      '${VN} ; ${VT} ;${RID} ;${CT.toString()}',
      style: SunmiQrcodeStyle(
        align: SunmiPrintAlign.CENTER,
        qrcodeSize: 8,
        errorLevel: SunmiQrcodeLevel.LEVEL_Q,
      ),
    );

    await SunmiPrinter.lineWrap(30);

    await SunmiPrinter.printText(
      "For your own convenience, please don't loose this slip'.\nIn case of lost, full charges will apply.",
      style: SunmiTextStyle(bold: true, fontSize: 30),
    );

    await SunmiPrinter.lineWrap(140); // Jump 2 lines

    // await _senraisePrinterPlugin.setAlignment(0);
    // await _senraisePrinterPlugin.setTextBold(true);
    // await _senraisePrinterPlugin.setTextSize(40);
    // await _senraisePrinterPlugin.printText("Parking Slip\n");

    // // new txt from here##########
    // await _senraisePrinterPlugin.setAlignment(0);
    // await _senraisePrinterPlugin.nextLine(1);
    // await _senraisePrinterPlugin.setTextBold(false);
    // await _senraisePrinterPlugin.setTextSize(30);
    // await _senraisePrinterPlugin.printText(
    //   "Vehicle Number: ${VN} \nVehicle Type: ${VT} \nReceipt ID: ${RID} \nCheck-in Time: ${CT}",
    // );

    // //QR code data

    // await _senraisePrinterPlugin.nextLine(2);
    // await _senraisePrinterPlugin.setAlignment(1);
    // await _senraisePrinterPlugin.printQRCode(
    //   "${VN} ; ${VT} ;${RID} ;${CT.toString()}",
    //   7,
    //   4,
    // );

    // // new txt from here##########

    // await _senraisePrinterPlugin.nextLine(2);
    // await _senraisePrinterPlugin.setAlignment(0);
    // await _senraisePrinterPlugin.setTextBold(false);
    // await _senraisePrinterPlugin.setTextSize(30);
    // await _senraisePrinterPlugin.printText(
    //   "For your own convenience Please don't loose this slip'\nIn case of lost, full charges will be apply",
    // );

    // //gap for the butom #######################

    // await _senraisePrinterPlugin.nextLine(4);

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
      token: token, // Passing the dynamic token
    );

    print(checkInResponse);
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
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

                    // conveti it in icone
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

                // hevy truck ?????????????????????????????
                SizedBox(
                  height: 160,
                  width: 160,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        VehicleType = "HEAVY_VEHICLE";
                      });
                      _showPopup(context);
                    },
                    child: Card(
                      elevation: 20,
                      color: Colors.white,
                      child: Image.asset("assets/big.png"),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // exit point #########################################
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

  // void goto_history() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => HistoryPage()),
  //   );
  // }

  void goto_exit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Exit()));
  }
}
