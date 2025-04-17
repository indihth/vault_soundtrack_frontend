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
  void onAuthSuccess() async {
    try {
      // Get the current Firebase user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Refresh the user's Firebase token
        idToken = await user.getIdToken(true);

        // Update UserState
        context.read<UserState>().setSpotifyConnection(true);

        // Navigate to home after successful connection
        Navigator.pushReplacementNamed(context, '/home');
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
              // const SizedBox(height: 20),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome ${userState.displayName}!\nConnect to Spotify',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'We use your listening history to find you favourite songs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SpotifyAuthButton(onAuthSuccess: onAuthSuccess),
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
