import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/auth/login_or_register.dart';
import 'package:vault_soundtrack_frontend/pages/connect_spotify_page.dart';
import 'package:vault_soundtrack_frontend/pages/home_page.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late UserState _userState;

  @override
  void initState() {
    super.initState();

    // Initialize UserState
    _userState = Provider.of<UserState>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // listens to auth state - if user is logged in or not
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show login/register if not authenticated
          if (!snapshot.hasData) {
            return LoginOrRegister();
          }

          // User is authenticated, now check Spotify connection
          return FutureBuilder<void>(
            // Trigger UserState update which checks Spotify connection
            future: _userState.updateUserState(),
            builder: (context, _) {
              return Consumer<UserState>(
                builder: (context, userState, _) {
                  // If not connected to Spotify, force ConnectSpotifyPage
                  if (!userState.isSpotifyConnected) {
                    return PopScope(
                      // onWillPop: () async => false, // Prevent back navigation
                      child: const ConnectSpotifyPage(),
                    );
                  }

                  // Only show HomePage if both authenticated and Spotify connected
                  return HomePage();
                },
              );
            },
          );

          // // if user is logged in
          // if (snapshot.hasData) {
          //   return HomePage();
          // } else {
          //   // if user is not logged in
          //   return LoginOrRegister();
          // }
        },
      ),
    );
  }
}
