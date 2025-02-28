import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:vault_soundtrack_frontend/components/spotify_auth_button.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // get current user id
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String? idToken;

  logout() async {
    // sign user out
    await FirebaseAuth.instance.signOut();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // This function will be called after successful Spotify authentication
  void onAuthSuccess() async {
    try {
      // Get the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Refresh the user's Firebase token
        idToken = await user.getIdToken(true);

        // Here you can:
        // 1. Fetch user's Spotify profile information
        // 2. Update local state to reflect the connected Spotify account
        // 3. Navigate to a different screen if needed

        print("Spotify authentication successful for user: ${user.uid}");

        // You might want to store a flag in shared preferences to remember that
        // the user has connected their Spotify account
        // await SharedPreferences.getInstance().then((prefs) {
        //   prefs.setBool('isSpotifyConnected', true);
        // });
      }
    } catch (e) {
      print("Error in onAuthSuccess: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [SpotifyAuthButton(onAuthSuccess: onAuthSuccess)],
        ),
      ),
    );
  }
}
