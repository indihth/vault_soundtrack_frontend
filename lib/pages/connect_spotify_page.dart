import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/spotify_auth_button.dart';

class ConnectSpotifyPage extends StatefulWidget {
  const ConnectSpotifyPage({super.key});

  @override
  State<ConnectSpotifyPage> createState() => _ConnectSpotifyPageState();
}

class _ConnectSpotifyPageState extends State<ConnectSpotifyPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String? idToken;

  // This function will be called after successful Spotify authentication
  void onAuthSuccess() async {
    try {
      // Get the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Refresh the user's Firebase token
        idToken = await user.getIdToken(true);
        print("Spotify authentication successful for user: ${user.uid}");
      }
    } catch (e) {
      print("Error in onAuthSuccess: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Create Session'),s
          ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
              Text('Connect Spotify Page'),
            ],
          ),
        ),
      ),
    );
  }
}
