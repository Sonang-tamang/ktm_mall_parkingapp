// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

// class QRViewExample extends StatefulWidget {
//   const QRViewExample({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => _QRViewExampleState();
// }

// class _QRViewExampleState extends State<QRViewExample> {
//   Barcode? result;
//   QRViewController? controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   String? _newresult;

//   @override
//   void reassemble() {
//     super.reassemble();
//     controller?.resumeCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: <Widget>[
//           Expanded(flex: 4, child: _buildQrView(context)),
//           Expanded(
//             flex: 3,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 if (result != null)
//                   Text('Data: ${result!.code}')
//                 else
//                   const Text('Scan a code'),
//                 ElevatedButton(
//                   onPressed: () async {
//                     await controller?.toggleFlash();
//                     setState(() {});
//                     print("qr data hello =${_newresult}");
//                   },
//                   child: FutureBuilder(
//                     future: controller?.getFlashStatus(),
//                     builder: (context, snapshot) {
//                       return Text('Flash: ${snapshot.data}');
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildQrView(BuildContext context) {
//     var scanArea = 300.0;
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: _onQRViewCreated,
//       overlay: QrScannerOverlayShape(
//         borderColor: Colors.red,
//         borderRadius: 10,
//         borderLength: 30,
//         borderWidth: 10,
//         cutOutSize: scanArea,
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     setState(() {
//       this.controller = controller;
//     });
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//         _newresult = result!.code;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
