import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'dart:convert';

import 'package:vault_soundtrack_frontend/components/spotify_auth_button.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get current user id
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String? sessionMessage; // message from the server API request
  List<String> sessions = []; // list of sessions from the server API request

  String? idToken;

  handleStartSession() async {
    try {
      // make the API request and store in response
      String response = await UserServices.createPlaylistSession();

      // set the response to the sessionMessage state
      setState(() {
        sessionMessage = response;
      });
    } catch (e) {
      setState(() {
        sessionMessage = e.toString();
      });
    }
  }

  handleGetSessions() async {
    try {
      // make the API request and store in response
      List<String> response = await UserServices.getPlaylistSessions();

      // set the response to the sessionMessage state
      setState(() {
        sessionMessage = response.toString();
      });
    } catch (e) {
      setState(() {
        sessionMessage = e.toString();
      });
    }
  }

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
          children: [
            SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
            MyButton(text: "Start session", onTap: handleStartSession),
            SizedBox(height: 20),
            Text(
              sessionMessage ?? "Press the button to create a session",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            MyButton(
                text: "Gets sessions", onTap: UserServices.getPlaylistSessions),
            SizedBox(height: 20),
            Text(
              sessionMessage ?? "Press the button to create a session",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
