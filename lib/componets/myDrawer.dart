// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pakingapp/componets/change_base_rate_dialog.dart';
import 'package:pakingapp/pages/data_view.dart';

class Mydrawer extends StatefulWidget {
  const Mydrawer({super.key});

  @override
  State<Mydrawer> createState() => _MydrawerState();
}

class _MydrawerState extends State<Mydrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      child: Drawer(
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Change Base Rate Option
            ListTile(
              leading: Icon(Icons.currency_exchange, color: Colors.blue),
              title: Text("Change Base Rate", style: TextStyle(fontSize: 16)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ChangeBaseRateDialog(); // Show the custom dialog
                  },
                );

                print("Change Base Rate Tapped");
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.blue),
              title: Text("Data", style: TextStyle(fontSize: 16)),
              onTap: () {
                goto_data();

                print("Data");
              },
            ),

            Divider(),
            // Another Placeholder Item (Optional)
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text("Settings", style: TextStyle(fontSize: 16)),
              onTap: () {
                // Add functionality here
                print("Settings Tapped");
              },
            ),
          ],
        ),
      ),
    );
  }

  void goto_data() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewDataPage()),
    );
  }
}
