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

  double currentTwoRate = 0;
  double currentFourRate = 0;
  String token = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    double? storedTwoWheelerRate = prefs.getDouble('two_wheeler_rate');
    double? storedFourWheelerRate = prefs.getDouble('four_wheeler_rate');
    String? storedToken = prefs.getString('token');

    print('Stored Two-Wheeler Rate: $storedTwoWheelerRate');
    print('Stored Four-Wheeler Rate: $storedFourWheelerRate');
    print('Stored token: $storedToken');

    if (mounted) {
      setState(() {
        currentTwoRate = storedTwoWheelerRate ?? 0;
        currentFourRate = storedFourWheelerRate ?? 0;
        token = storedToken ?? "";
      });
    }
  }

  void updateRates() async {
    double? parseDouble(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      return double.tryParse(value.trim());
    }

    final two = parseDouble(_two.text);
    final four = parseDouble(_four.text);

    print('Input - Two Wheeler: ${_two.text} Parsed: $two');
    print('Input - Four Wheeler: ${_four.text} Parsed: $four');
    print('Token: $token');

    if (two == null || four == null) {
      print('Validation failed: Invalid rates');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter valid rates')));
      return;
    }

    print('Calling BaseRateService.updateBaseRate...');
    bool success = await BaseRateService.updateBaseRate(token, two, four);

    print('UpdateBaseRate result: $success');

    if (success) {
      print('Rates updated successfully');
      await fetchRates();
      goto_home();
    } else {
      print('Failed to update rates');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update rates')));
    }
  }

  void goto_home() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
    );
  }

  Future<void> fetchRates() async {
    var rates = await BaseRateService.getBaseRates(token);
    if (rates != null) {
      print('Fetched Two-wheeler rate: ${rates['two_wheeler_rate']}');
      print('Fetched Four-wheeler rate: ${rates['four_wheeler_rate']}');
      if (mounted) {
        setState(() {
          currentTwoRate = rates['two_wheeler_rate'];
          currentFourRate = rates['four_wheeler_rate'];
        });
      }
    } else {
      print('Failed to fetch rates');
    }
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Base Rate"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Two wheeler rate\nCurrent: RS $currentTwoRate",
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  width: 100,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _two,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Four wheeler rate\nCurrent: RS $currentFourRate",
                  style: const TextStyle(fontSize: 15),
                ),
                SizedBox(
                  width: 100,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _four,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              width: 120,
              child: InkWell(
                onTap: () {
                  updateRates();
                },
                child: Card(
                  color: Colors.blue,
                  child: const Center(
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
      ),
    );
  }
}
