// // import 'package:flutter/material.dart';
// // import 'package:pakingapp/database/parkingdatabase.dart';

// // class ViewDataPage extends StatefulWidget {
// //   @override
// //   _ViewDataPageState createState() => _ViewDataPageState();
// // }

// // class _ViewDataPageState extends State<ViewDataPage> {
// //   late Future<List<Map<String, dynamic>>> _dataFuture;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _dataFuture = fetchAllData();
// //   }

// //   Future<List<Map<String, dynamic>>> fetchAllData() async {
// //     final dbHelper = DatabaseHelper.instance;
// //     final db = await dbHelper.database;

// //     // Fetch all records from ParkingData table
// //     return await db.query('ParkingData');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Parking Data History'),
// //       ),
// //       body: FutureBuilder<List<Map<String, dynamic>>>(
// //         future: _dataFuture,
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(child: CircularProgressIndicator());
// //           } else if (snapshot.hasError) {
// //             return Center(child: Text('Error: ${snapshot.error}'));
// //           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //             return Center(child: Text('No data available'));
// //           }

// //           final data = snapshot.data!;
// //           return ListView.builder(
// //             itemCount: data.length,
// //             itemBuilder: (context, index) {
// //               final record = data[index];
// //               return Card(
// //                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
// //                 child: ListTile(
// //                   title: Text('Receipt ID: ${record['receipt_id']}'),
// //                   subtitle: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text('Vehicle Number: ${record['vehicle_number']}'),
// //                       Text('Vehicle Type: ${record['vehicle_type']}'),
// //                       Text('Check-In: ${record['checkin_time']}'),
// //                       Text('check-In by: ${record['checkedin_by']}'),
// //                       Text(
// //                         'Check-Out: ${record['checkout_time'] ?? 'Not Checked Out'}',
// //                       ),
// //                       Text(
// //                           'check-out by: ${record['checkedout_by'] ?? 'Not Checked Out'}'),
// //                       Text('Amount: RS ${record['amount']}'),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:pakingapp/componets/exit_pop.dart';
// import 'package:pakingapp/database/parkingdatabase.dart';

// class ViewDataPage extends StatefulWidget {
//   @override
//   _ViewDataPageState createState() => _ViewDataPageState();
// }

// class _ViewDataPageState extends State<ViewDataPage> {
//   late Future<List<Map<String, dynamic>>> _dataFuture;
//   List<Map<String, dynamic>> _allData = [];
//   List<Map<String, dynamic>> _filteredData = [];
//   TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _dataFuture = fetchAllData();
//     _searchController.addListener(_filterData);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<Map<String, dynamic>>> fetchAllData() async {
//     final dbHelper = DatabaseHelper.instance;
//     final db = await dbHelper.database;

//     // Fetch all records from ParkingData table
//     final data = await db.query('ParkingData');
//     _allData = data; // Store all data for filtering
//     _filteredData = data; // Initially, filtered data is the same as all data
//     return data;
//   }

//   void _filterData() {
//     final query = _searchController.text.toLowerCase();

//     setState(() {
//       if (query.isEmpty) {
//         _filteredData = _allData; // Reset to all data if the search is empty
//       } else {
//         _filteredData = _allData.where((record) {
//           return record['receipt_id'].toLowerCase().contains(query) ||
//               record['vehicle_number'].toLowerCase().contains(query) ||
//               record['vehicle_type'].toLowerCase().contains(query);
//         }).toList();
//       }
//     });
//   }

//   void _showDetailsDialog(Map<String, dynamic> record) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return DetailsDialog(
//           record: record,
//           onCancel: () => Navigator.pop(context), // Close the dialog
//           onPrint: () {
//             _printReceipt(record);
//             Navigator.pop(context); // Close the dialog after printing
//           },
//         );
//       },
//     );
//   }

//   void _printReceipt(record) {
//     // Add your printing logic here
//     // For now, we'll simply print the record to the console
//     print('Printing receipt for: ${record['receipt_id']}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('View Parking Data'),
//       ),
//       body: Column(
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 hintText: 'Search by Receipt ID, Vehicle Number, or Type',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//           // Display the filtered data
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _dataFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || _filteredData.isEmpty) {
//                   return Center(child: Text('No data found'));
//                 }

//                 return ListView.builder(
//                   itemCount: _filteredData.length,
//                   itemBuilder: (context, index) {
//                     final record = _filteredData[index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                       child: ListTile(
//                         title: Text('Receipt ID: ${record['receipt_id']}'),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Vehicle Number: ${record['vehicle_number']}'),
//                             Text('Vehicle Type: ${record['vehicle_type']}'),
//                             Text('Check-In: ${record['checkin_time']}'),
//                             Text(
//                               'Check-Out: ${record['checkout_time'] ?? 'Not Checked Out'}',
//                             ),
//                             Text('Amount: \$${record['amount']}'),
//                           ],
//                         ),
//                         onLongPress: () {
//                           _showDetailsDialog(record); // Show the popup dialog
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pakingapp/componets/exit_pop.dart';
import 'package:pakingapp/database/parkingdatabase.dart';
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

class ViewDataPage extends StatefulWidget {
  @override
  _ViewDataPageState createState() => _ViewDataPageState();
}

class _ViewDataPageState extends State<ViewDataPage> {
  late Future<List<Map<String, dynamic>>> _dataFuture;
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  TextEditingController _searchController = TextEditingController();

  String VN = "";
  String VT = "";
  String RID = "";
  DateTime? CT;

  DateTime? CO;

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchAllData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchAllData() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;

    // Fetch all records from ParkingData table
    final data = await db.query('ParkingData');
    _allData = data; // Store all data for filtering
    _filteredData = data; // Initially, filtered data is the same as all data
    return data;
  }

  void _filterData() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredData = _allData; // Reset to all data if the search is empty
      } else {
        _filteredData =
            _allData.where((record) {
              return record['receipt_id'].toLowerCase().contains(query) ||
                  record['vehicle_number'].toLowerCase().contains(query) ||
                  record['vehicle_type'].toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  void _showDetailsDialog(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) {
        return DetailsDialog(
          record: record,
          onCancel: () => Navigator.pop(context), // Close the dialog
          onPrint: () {
            Navigator.pop(context); // Close the dialog after printing
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Parking Data')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search by Receipt ID, Vehicle Number, or Type',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Display the filtered data
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || _filteredData.isEmpty) {
                  return Center(child: Text('No data found'));
                }

                return ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    final record = _filteredData[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text('Receipt ID: ${record['receipt_id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vehicle Number: ${record['vehicle_number']}'),
                            Text('Vehicle Type: ${record['vehicle_type']}'),
                            Text('Check-In: ${record['checkin_time']}'),
                            Text(
                              'Check-Out: ${record['checkout_time'] ?? 'Not Checked Out'}',
                            ),
                            Text('Amount: RS ${record['amount']}'),
                          ],
                        ),
                        onLongPress: () {
                          _showDetailsDialog(record); // Show the popup dialog
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
