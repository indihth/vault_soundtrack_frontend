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
  MobileScannerController? cameraController;
  // final MobileScannerController cameraController = MobileScannerController();

  late SessionState _sessionState; // Declare the session state variable
  bool _isLoading =
      false; // To display loading indicator when waiting for API response

  String? scanResult;

  @override
  void initState() {
    super.initState();

    _sessionState = Provider.of<SessionState>(context, listen: false);
    cameraController =
        MobileScannerController(); // Start the camera when the widget is initialized
  }

  Future<void> _handleTap(context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      const sessionId = ApiConstants.sessionId;

      Map<String, dynamic> joined = await _sessionState.joinSession(sessionId);

      if (joined['success']) {
        // check if the response is successful
        await Navigator.pushReplacementNamed(context, '/waiting-room');

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Failed to join session: $e');
      // Show error dialog
      UIHelpers.showSnackBar(context, 'Failed to join session', isError: true);
    }
  }

  Map<String, dynamic> _parseQRCode(List<Barcode> barcodes) {
    if (barcodes.isEmpty || barcodes.first.rawValue == null) {
      throw Exception('Invalid QR code: No data found');
    }

    final String rawValue = barcodes.first.rawValue!;
    final List<String> parts = rawValue.split(',');

    // check if there's at least 1 string (sessionId)
    if (parts.isEmpty) {
      throw Exception('Invalid QR code format: Expected at least sessionId');
    }

    final String sessionId = parts[0].trim();

    // Validate sessionId length
    if (sessionId.length != 20) {
      throw Exception('Invalid session ID length');
    }

    // the 'late' flag is not always included, if exists and is true set it to true
    final bool isLateJoin =
        parts.length > 1 ? parts[1].trim().toLowerCase() == 'late' : false;

    return {
      'sessionId': sessionId,
      'isLateJoin': isLateJoin,
    };
  }

  void _processScanResult(List<Barcode> barcodes) async {
    try {
      // Display loading indicator while waiting
      setState(() {
        _isLoading = true;
      });

      // parse the qr code to get sessionId and isLateJoin values
      final {'sessionId': sessionId, 'isLateJoin': isLateJoin} =
          _parseQRCode(barcodes);

      // Join session
      final result =
          await _sessionState.joinSession(sessionId, isLateJoin: isLateJoin);

      // navigate depending on isLateJoin or not
      if (result['isLateJoin']) {
        await Navigator.pushNamed(context, '/live-session');
      } else {
        await Navigator.pushNamed(context, '/waiting-room');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

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
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Join a Session',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 60),
                  SizedBox(
                    height: 400,
                    child: MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;

                        // handle detected barcode
                        if (barcodes.isNotEmpty) {
                          cameraController?.stop();

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('QR Code Detected'),
                              content:
                                  Text('Would you like to join the session?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    cameraController?.start();
                                    Navigator.pop(context);
                                    // Resume scanning if you paused it
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    print('Joining session...');

                                    _processScanResult(barcodes);
                                    Navigator.pop(context);
                                    // Resume scanning if you paused it
                                    // cameraController.start();
                                  },
                                  child: const Text('Join'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          print("Invalid QR code ##########################");
                        }
                        //   }
                        // }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      scanResult ?? 'Scan a QR code',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
