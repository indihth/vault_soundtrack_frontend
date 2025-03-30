import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
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

class _JoinSessionPageState extends State<JoinSessionPage> {
  final MobileScannerController cameraController = MobileScannerController(
      // required options for the scanner
      );

  String? scanResult;

  Future<void> _handleTap(context) async {
    try {
      const sessionId = ApiConstants.sessionId;
      Map<String, dynamic> joined =
          await PlaylistSessionServices.joinPlaylistSession(sessionId);
      if (joined['success']) {
        // check if the response is successful
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
      final sessionState = Provider.of<SessionState>(context, listen: false);

      Map<String, dynamic> joined = await sessionState.joinSession(sessionId);
      print("inside process scan result: $sessionId");

      if (joined['success']) {
        Navigator.pushNamed(context, '/waiting-room');
        print("joined session!!");
      }
    } catch (e) {
      // Handle error
      print('Failed to join session: $e');
      // Show error dialog
      UIHelpers.showSnackBar(context, 'Failed to join session',
          isError: true); // warning about context, widget is unmounted?
    }
  }

  @override
  void dispose() {
    // dispose of the controller when the widget is removed
    cameraController.dispose();
    super.dispose();
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
                flex: 3,
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;

                    // handle detected barcode
                    if (barcodes.isNotEmpty) {
                      final Barcode barcode = barcodes.first;

                      // Check if the barcode has a displayValue (the actual scanned content)
                      if (barcodes.isNotEmpty &&
                          barcodes.first.rawValue != null) {
                        final String sessionId = barcodes.first.rawValue!;

                        // Check if the scanned value matches a valid session ID format, 20 character string
                        if (sessionId.length == 20) {
                          // if (scannedUrl.startsWith(
                          //     'sample://open.my.app/#/join-session/')) {
                          // final sessionId = "eM4zvPgXFi0goK1XNnvq";
                          print('Scanned URL: $sessionId');

                          // You can also pause scanning after detecting a code
                          cameraController.stop();

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('QR Code Detected'),
                              content: Text('Content: ${barcode.rawValue}'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    print('Joining session...');

                                    _processScanResult(sessionId);
                                    Navigator.pop(context);
                                    // Resume scanning if you paused it
                                    // cameraController.start();
                                  },
                                  child: const Text('Join Session'),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // Resume scanning if you paused it
                                      cameraController.start();
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
                  },
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
        ),
      ),
    );
  }
}
