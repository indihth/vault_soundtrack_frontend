import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class SpotifyAuthButton extends StatelessWidget {
  // server endpoint url
  final String serverUrl =
      "http://10.0.2.2:3050/api"; // 10.0.2.2 instead of 'localhost' for Android emulator to access physical machine
  final VoidCallback onAuthSuccess;

  const SpotifyAuthButton({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DB954), // Spotify green
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: () => _startAuthFlow(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, color: Colors.white),
          SizedBox(width: 8),
          Text('Connect to Spotify',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // _ naming convention indicates a private function only accessible within this file
  Future<void> _startAuthFlow(BuildContext context) async {
    try {
      _showLoadingIndicator(context);

      // start the Spotify authentication flow using flutter_web_auth package
      final result = await FlutterWebAuth2.authenticate(
        url: '$serverUrl/spotify/login',
        callbackUrlScheme:
            "spotifyauth", // this should match the callbackUrlScheme in the server - custom url scheme
      );

// hide loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // if authentication was successful
      // browser will auto close when redirected to callbackUrlScheme
      onAuthSuccess();

      // success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully connected to Spotify!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
// hide loading indicator if it's showing
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Authentication was canceled or failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to Spotify: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Failed to connect to Spotify: ${e.toString()}');
    }
  }

  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
