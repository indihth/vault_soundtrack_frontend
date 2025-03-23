import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vault_soundtrack_frontend/utils/constants.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class JoinSessionPage extends StatefulWidget {
  const JoinSessionPage({super.key, required this.sessionId});
  final String sessionId;

  @override
  State<JoinSessionPage> createState() => _JoinSessionPageState();
}

class _JoinSessionPageState extends State<JoinSessionPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
      // required options for the scanner
      );
  StreamSubscription<Object?>? _subscription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  Barcode? _barcode;
  String? scanResult;

  Future<void> _cleanupCamera() async {
    await _subscription?.cancel();
    _subscription = null;
    await controller.stop();
    await controller.dispose();
  }

  Future<void> _handleTap(context) async {
    try {
      await _cleanupCamera(); // Add cleanup before navigation
      const sessionId = ApiConstants.sessionId;
      bool joined =
          await PlaylistSessionServices.joinPlaylistSession(sessionId);
      if (joined && mounted) {
        Navigator.pushNamed(context, '/waiting-room');
        print("joined session!!");
      }
    } catch (e) {
      // Handle error
      print('Failed to join session: $e');
      // Show error dialog
      UIHelpers.showSnackBar(context, 'Failed to join session', isError: true);
    }
  }

  void _processScanResult(String sessionId) async {
    try {
      await _cleanupCamera(); // Add cleanup before navigation
      bool joined =
          await PlaylistSessionServices.joinPlaylistSession(sessionId);
      if (joined && mounted) {
        Navigator.pushNamed(context, '/waiting-room');
      }
    } catch (e) {
      print('Failed to join session: $e');
      if (mounted) {
        UIHelpers.showSnackBar(context, 'Failed to join session',
            isError: true);
      }
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
    }
    print('Barcode detected: ${_barcode?.rawValue}');
    if (_barcode != null) {
      final String scannedUrl = _barcode!.rawValue!;

      if (scannedUrl.startsWith('sample://open.my.app/#/join-session/')) {
        // extract session id from deep link
        final sessionId = scannedUrl.split('/').last;
        print('Scanned URL: $sessionId');

        // You can also pause scanning after detecting a code
        controller.stop();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('QR Code Detected'),
            content: Text('Content: ${_barcode!.rawValue}'),
            actions: [
              TextButton(
                onPressed: () {
                  print('Joining session...');

                  _processScanResult(sessionId);
                  Navigator.pop(context);
                  // Resume scanning if you paused it
                  controller.start();
                },
                child: const Text('Join Session'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Resume scanning if you paused it
                    controller.start();
                  },
                  child: const Text('Cancel'))
            ],
          ),
        );
      } else {
        print("Invalid QR code ##########################");
      }
    }
  }

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Join Session Page'),
              MyButton(
                text: 'Join a session',
                onTap: () => _handleTap(context),
              ), // wrap in anon function to pass context
              Expanded(
                child: MobileScanner(
                  onDetect: _handleBarcode,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Center(child: _buildBarcode(_barcode))),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //   flex: 3,
              //   child: MobileScanner(
              //     controller: cameraController,
              //     onDetect: (capture) {
              //       final List<Barcode> barcodes = capture.barcodes;

              //       // handle detected barcode
              //       if (barcodes.isNotEmpty) {
              //         final Barcode barcode = barcodes.first;

              //         // Check if the barcode has a displayValue (the actual scanned content)
              //         if (barcodes.isNotEmpty &&
              //             barcodes.first.rawValue != null) {
              //           final String scannedUrl = barcodes.first.rawValue!;

              //           if (scannedUrl.startsWith(
              //               'sample://open.my.app/#/join-session/')) {
              //             // extract session id from deep link
              //             // final sessionId = scannedUrl.split('/').last;
              //             final sessionId = "eM4zvPgXFi0goK1XNnvq";
              //             print('Scanned URL: $sessionId');

              //             // You can also pause scanning after detecting a code
              //             cameraController.stop();

              //             showDialog(
              //               context: context,
              //               builder: (context) => AlertDialog(
              //                 title: const Text('QR Code Detected'),
              //                 content: Text('Content: ${barcode.rawValue}'),
              //                 actions: [
              //                   TextButton(
              //                     onPressed: () {
              //                       print('Joining session...');

              //                       _processScanResult(sessionId);
              //                       Navigator.pop(context);
              //                       // Resume scanning if you paused it
              //                       // cameraController.start();
              //                     },
              //                     child: const Text('Join Session'),
              //                   ),
              //                   TextButton(
              //                       onPressed: () {
              //                         Navigator.pop(context);
              //                         // Resume scanning if you paused it
              //                         cameraController.start();
              //                       },
              //                       child: const Text('Cancel'))
              //                 ],
              //               ),
              //             );
              //           } else {
              //             print("Invalid QR code ##########################");
              //           }
              //         }
              //       }
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
