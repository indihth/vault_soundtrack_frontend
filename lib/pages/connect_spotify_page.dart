import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';
import 'package:vault_soundtrack_frontend/widgets/spotify_auth_button.dart';

class ConnectSpotifyPage extends StatefulWidget {
  const ConnectSpotifyPage({super.key});

  @override
  State<ConnectSpotifyPage> createState() => _ConnectSpotifyPageState();
}

class _ConnectSpotifyPageState extends State<ConnectSpotifyPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  String? idToken;

  // This function will be called after successful Spotify authentication
  void onAuthSuccess(bool success) async {
    if (!success || !mounted)
      return; // don't proceed if not successful or widget is unmounted

    try {
      // Get the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Refresh the user's Firebase token
        idToken = await user.getIdToken(true);

        // Update UserState
        if (mounted) {
          final userState = Provider.of<UserState>(context, listen: false);
          userState.setSpotifyConnection(true);
          userState.clearNewUserFlag(); // Set new user flag to false
        }

        // // Navigate to home after successful connection
        // Navigator.pushReplacementNamed(context, '/home');

        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home', (route) => false // remove all previous routes
            );
      }
    } catch (e) {
      print("Error in onAuthSuccess: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0
          // title: const Text('Create Session'),s
          ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/vt_logo.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect to \nSpotify',
                            // 'Welcome ${userState.displayName}! \nConnect to \nSpotify',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "We'll gather your listening history to create a customized experience.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          // const SizedBox(height: 50),
                        ],
                      ),
                      SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
