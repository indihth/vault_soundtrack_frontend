import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/services/spotify_services.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // get current user id
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String? sessionMessage; // message from the server API request
  Map<String, dynamic>? playlistResult; // message from the server API request
  List<String> sessions = []; // list of sessions from the server API request

  String? idToken;

  handleCreatePlaylist() async {
    try {
      Map<String, dynamic> response = await SpotifyServices.createPlaylist();
      setState(() {
        playlistResult = response;
      });

      if (response['requiresAuth']) {
        UIHelpers.showSnackBar(
            context, 'This action requires Spotify authentication',
            isError: true);
      } else {
        UIHelpers.showSnackBar(context, 'Playlist created successfully',
            isError: false);
      }
      print('playlist results: $playlistResult');
    } catch (e) {
      throw Exception('Failed to create playlist: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
              MyButton(
                  text: "Connect Spotify",
                  onTap: () {
                    Navigator.pushNamed(context, '/connect-spotify');
                  }),
              SizedBox(height: 20),
              MyButton(
                text: "Start session",
                onTap: () {
                  Navigator.pushNamed(context, '/create-session');
                },
              ),
              SizedBox(height: 20),
              MyButton(
                text: "Join session",
                onTap: () {
                  Navigator.pushNamed(context, '/join-session');
                },
              ),
              SizedBox(height: 20),
              MyButton(
                text: "Live Session",
                onTap: () {
                  Navigator.pushNamed(context, '/live-session');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
