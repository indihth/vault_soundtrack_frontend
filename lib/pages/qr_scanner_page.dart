import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QRScannerPage(),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  // Create a controller for the scanner
  // This controller allows you to interact with the scanner
  MobileScannerController cameraController = MobileScannerController();

  // Keep track of the scan result
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        // actions: [
        //   // Toggle flash button
        //   IconButton(
        //     color: Colors.white,
        //     icon: ValueListenableBuilder(
        //       valueListenable: cameraController.torchState,
        //       builder: (context, state, child) {
        //         // Show different icons based on torch state
        //         switch (state) {
        //           case TorchState.off:
        //             return const Icon(Icons.flash_off, color: Colors.grey);
        //           case TorchState.on:
        //             return const Icon(Icons.flash_on, color: Colors.yellow);
        //         }
        //       },
        //     ),
        //     // Toggle torch when pressed
        //     onPressed: () => cameraController.toggleTorch(),
        //   ),
        //   // Toggle camera button (front/back)
        //   IconButton(
        //     color: Colors.white,
        //     icon: ValueListenableBuilder(
        //       valueListenable: cameraController.cameraFacingState,
        //       builder: (context, state, child) {
        //         switch (state) {
        //           case CameraFacing.front:
        //             return const Icon(Icons.camera_front);
        //           case CameraFacing.back:
        //             return const Icon(Icons.camera_rear);
        //         }
        //       },
        //     ),
        //     // Switch between front and back camera
        //     onPressed: () => cameraController.switchCamera(),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            // The MobileScanner widget is the main component that handles scanning
            child: MobileScanner(
              // Pass the controller we created
              controller: cameraController,
              // Set to true to overlay the barcode on the screen
              overlayBuilder: (context, constraints) => Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              // The onDetect callback is called when a barcode/QR code is detected
              onDetect: (capture) {
                // The capture object contains a list of barcodes
                final List<Barcode> barcodes = capture.barcodes;

                // Handle the first detected barcode
                if (barcodes.isNotEmpty) {
                  final Barcode barcode = barcodes.first;

                  // Check if the barcode has a displayValue (the actual scanned content)
                  if (barcode.rawValue != null &&
                      scanResult != barcode.rawValue) {
                    // Update the scan result
                    setState(() {
                      scanResult = barcode.rawValue;
                    });

                    // Optional: Play a sound or vibration on successful scan
                    // You would need to add another package for this, e.g., flutter_sound

                    // You can also pause scanning after detecting a code
                    // cameraController.stop();

                    // Optional: Show a dialog with the scan result
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('QR Code Detected'),
                        content: Text('Content: ${barcode.rawValue}'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Resume scanning if you paused it
                              // cameraController.start();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              // // Error handling for camera issues
              // onError: (error) {
              //   // Handle any camera errors
              //   print('Scanner error: $error');

              //   // Show a message to the user
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text('Scanner error: $error'),
              //       duration: const Duration(seconds: 3),
              //     ),
              //   );
              // },
            ),
          ),
          // Display the scan result
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scanResult ?? 'Scan a QR code',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Always dispose of the controller when the widget is disposed
    cameraController.dispose();
    super.dispose();
  }
}

// 3. Permissions Setup:
// For Android: Add the following to your AndroidManifest.xml (android/app/src/main/AndroidManifest.xml)
// <uses-permission android:name="android.permission.CAMERA" />

// For iOS: Add the following to your Info.plist (ios/Runner/Info.plist)
// <key>NSCameraUsageDescription</key>
// <string>This app uses the camera to scan QR codes</string>

// 4. Common Issues:
// - If camera doesn't work, check if permissions were properly set up
// - For web support, additional configuration is needed
// - Test on real devices, as emulators might not support camera functionality properly
