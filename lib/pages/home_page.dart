import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/current_session_card.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:vault_soundtrack_frontend/services/spotify_services.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/my_icon_button.dart';
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
        automaticallyImplyLeading: false, // automatically hides added back btn

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
              Text(
                "Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}",
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyIconButton(
                      primary: true,
                      iconType: Icons.add,
                      callback: () {
                        Navigator.pushNamed(context, '/create-session');
                      },
                      text: "Create new \nsession"),
                  MyIconButton(
                      iconType: Icons.qr_code_outlined,
                      callback: () {
                        Navigator.pushNamed(context, '/join-session');
                      },
                      text: "Join a \nsession"),
                ],
              ),
              SizedBox(height: 20),
              CurrentSessionCard(),
              SizedBox(height: 20),

              // MyButton(
              //     text: "Connect Spotify",
              //     onTap: () {
              //       Navigator.pushNamed(context, '/connect-spotify');
              //     }),
              // SizedBox(height: 20),
              // MyButton(
              //   text: "Join session",
              //   onTap: () {
              //     Navigator.pushNamed(context, '/join-session');
              //   },
              // ),
              SizedBox(height: 20),
              MyButton(
                text: "User's Sessions",
                onTap: () {
                  Navigator.pushNamed(context, '/user-sessions');
                },
              ),
              // 4. Session history title and optional button
              Text(
                "Past Sessions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  Provider.of<SessionState>(context, listen: false)
                      .refreshSessions();
                },
              ),
              SizedBox(height: 10),

              // 5. Expandable past sessions list - this will take remaining space
              Expanded(
                child:
                    PastSessions(), // Use a content-only widget (defined below)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
