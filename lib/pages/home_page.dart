import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/primary_session_card.dart';
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
  late SessionState _sessionState;

  String? sessionMessage; // message from the server API request
  Map<String, dynamic>? playlistResult; // message from the server API request
  List<String> sessions = []; // list of sessions from the server API request

  String? idToken;

  @override
  void initState() {
    super.initState();

    _sessionState = Provider.of<SessionState>(context, listen: false);

    // only load after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionState
          .loadSessions(); // load sessions when the widget is initialized
    });
  }

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
    final userState = Provider.of<UserState>(context, listen: false);
    try {
      print('Logout started');

      if (userState.isLoggingOut) return; // prevent multiple logouts

      // sets the logout flag to true - AuthPage listens and handles state changes
      userState.startLogout();

      await FirebaseAuth.instance.signOut();
      // clear states
      _sessionState.clearSessionState();
      _sessionState.clearViewingState();

      print('Firebase signOut completed');
// force rebuild of the widget tree to update the UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error logging out: $e');
      if (mounted) {
        UIHelpers.showSnackBar(context, 'Error signing out', isError: true);
      }
    } finally {
      // Reset the logout flag after the operation is complete
      userState.endLogout();
      print('Logout process finished');
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
            mainAxisAlignment:
                MainAxisAlignment.start, // Changed from spaceBetween to start
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User greeting section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  SizedBox(height: 48),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  )
                ],
              ),

              // Current session card - not in an Expanded widget
              PrimarySessionCard(),

              // Past sessions - wrapped in Expanded to fill remaining space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Past Sessions",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            _sessionState.loadSessions();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Make PastSessions fill the remaining space in the column
                    Expanded(
                      child: PastSessions(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
