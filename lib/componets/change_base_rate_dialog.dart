import 'package:flutter/material.dart';
import 'package:pakingapp/API/Rate_API.dart';
import 'package:pakingapp/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeBaseRateDialog extends StatefulWidget {
  const ChangeBaseRateDialog({super.key});

  @override
  State<ChangeBaseRateDialog> createState() => _ChangeBaseRateDialogState();
}

class _ChangeBaseRateDialogState extends State<ChangeBaseRateDialog> {
  final TextEditingController _two = TextEditingController();
  final TextEditingController _four = TextEditingController();
  final TextEditingController _heavy = TextEditingController();
  final TextEditingController _passcode = TextEditingController();

  double crunnet_two_rate = 0;
  double crunnet_four_rate = 0;
  double crunnet_heavy_rate = 0;
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

    // Log the values
    print('Stored Two-Wheeler Rate: $storedTwoWheelerRate');
    print('Stored Four-Wheeler Rate: $storedFourWheelerRate');
    print('Stored Heavy Vehicle Rate: $storedHeavyVehicleRate');
    print('Store token $storedtoken');

    // Update the state to reflect changes
    // setState(() {
    //   crunnet_two_rate = storedTwoWheelerRate ?? 0; // Default to 0 if not found
    //   crunnet_four_rate = storedFourWheelerRate ?? 0;
    //   crunnet_heavy_rate = storedHeavyVehicleRate ?? 0;
    //   token = storedtoken ?? "";
    // });
    if (mounted) {
      setState(() {
        crunnet_two_rate =
            storedTwoWheelerRate ?? 0; // Default to 0 if not found
        crunnet_four_rate = storedFourWheelerRate ?? 0;
        crunnet_heavy_rate = storedHeavyVehicleRate ?? 0;
        token = storedtoken ?? "";
      });
    }
  }

  // Update the rates on the server
  void updateRates() async {
    String passcode =
        _passcode.text.trim(); // Replace with the correct passcode

    double two = double.parse(_two.text.trim());
    double four = double.parse(_four.text.trim());
    double heavy = double.parse(_heavy.text.trim());
    bool success = await BaseRateService.updateBaseRate(
      token,
      two, // Two-wheeler rate
      four, // Four-wheeler rate
      heavy, // Heavy vehicle rate
      passcode,
    );

    if (success) {
      print('Rates updated successfully');
      fetchRates();
      goto_home();
    } else {
      print('Failed to update rates');
    }
  }

  void goto_home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
    );
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
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Base Rate"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "two wheeler rate \nCurrent: RS $crunnet_two_rate",
                      style: TextStyle(fontSize: 15),
                    ),

                    // text fild ###########################33
                    SizedBox(
                      width: 100,
                      height: 60,
                      child:
                      // text fild ############
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _two,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            // labelText: "username*",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),

                // second fild ########################################################
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "four wheeler rate\nCurrent: RS $crunnet_four_rate",
                      style: TextStyle(fontSize: 15),
                    ),

                    // text fild ###########################33
                    SizedBox(
                      width: 100,
                      height: 60,
                      child:
                      // text fild ############
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _four,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            // labelText: "username*",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),

                // thinrd fild ###########################################################3
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "heavy vehicle rate\nCurrent: RS $crunnet_heavy_rate",
                      style: TextStyle(fontSize: 15),
                    ),

                    // text fild ###########################33
                    SizedBox(
                      width: 100,
                      height: 60,
                      child:
                      // text fild ############
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _heavy,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),

                            // labelText: "username*",
                            hintStyle: TextStyle(fontWeight: FontWeight.w300),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Text("Enter your passcode", style: TextStyle(fontSize: 16)),

                // text fild ############
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _passcode,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),

                      // labelText: "username*",
                      hintStyle: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    // keyboardType: TextInputType.number,
                  ),
                ),

                // button for updating ##################################
                SizedBox(
                  height: 70,
                  width: 120,
                  child: InkWell(
                    onTap: () {
                      updateRates();
                    },
                    child: Card(
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
}
