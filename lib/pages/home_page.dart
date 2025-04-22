import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/services/spotify_services.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/past_sessions.dart';
import 'package:vault_soundtrack_frontend/widgets/session_card.dart';

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
    try {
      final userState = Provider.of<UserState>(context, listen: false);

      // if (userState.isLoggingOut) return; // prevent multiple logouts
      print('Logging out...');

      // sets the logout flag to true - AuthPage listens and handles state changes
      // to avoid calling setState on unmounted widget
      userState.startLogout();

      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        UIHelpers.showSnackBar(context, 'Error signing out', isError: true);
      }

      // reset logout flag if error occurs
      final userState = Provider.of<UserState>(context, listen: false);
      userState.endLogout();
    }
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
            onPressed: () {
              logout();
            },
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
              Text(
                "Welcome, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 20),
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
                text: "User's Sessions",
                onTap: () {
                  Navigator.pushNamed(context, '/user-sessions');
                },
              ),
              PastSessions(),
            ],
          ),
        ),
      ),
    );
  }
}
