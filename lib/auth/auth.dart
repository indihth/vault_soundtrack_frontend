import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/auth/login_or_register.dart';
import 'package:vault_soundtrack_frontend/pages/connect_spotify_page.dart';
import 'package:vault_soundtrack_frontend/pages/home_page.dart';
import 'package:vault_soundtrack_frontend/state/user_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // loading indicator
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // listens to auth state - if user is logged in or not
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('Auth state changed: hasData=${snapshot.hasData}');
          print('Auth state user: ${FirebaseAuth.instance.currentUser?.uid}');
          // Show login/register if not authenticated
          if (!snapshot.hasData) {
            print('No auth data - should show login page');
            return LoginOrRegister();
          } else {
            // Check if user is new and needs to connect to Spotify

            return Consumer<UserState>(builder: (context, userState, _) {
              // Handle null case for isNewUser
              // if (userState.isNewUser == null) {
              //   print('userState should be null: ${userState.isNewUser}');
              //   return const Center(child: CircularProgressIndicator());
              // }

              // If this is a new registration, show the Spotify connect page
              if (userState.isNewUser) {
                print('userState should be true: ${userState.isNewUser}');
                return ConnectSpotifyPage();
              }

              print('userState should be false: ${userState.isNewUser}');
              return HomePage();

              // Otherwise show the home page
            });
          }

          // If we haven't initialized user state yet or it's loading, show loading
          // if (_isLoading || !_isInitialized) {
          //   return const Center(child: CircularProgressIndicator());
          // }

          // User is authenticated, now check Spotify connection
          // return Consumer<UserState>(
          //   builder: (context, userState, _) {
          //     // If not connected to Spotify, force ConnectSpotifyPage
          //     if (userState.isNewUser && !userState.isSpotifyConnected) {
          //       return PopScope(
          //         child: const ConnectSpotifyPage(),
          //       );
          //     } else if (userState.isNewUser && userState.isSpotifyConnected) {
          //       // only after widget is built - avoids calling setState on unmounted widget
          //       // previousl setup caused a flash of the homescreen before the transition to ConnectSpotifyPage

          //       // schedules navigation callback after the widget is built
          //       Future.microtask(() {
          //         userState.clearNewUserFlag();
          //         Navigator.of(context).pushAndRemoveUntil(
          //             MaterialPageRoute(builder: (_) => HomePage()),
          //             (route) => false // remove all previous routes
          //             );
          //       });

          //       // laoding indicator during the transition
          //       return Center(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             CircularProgressIndicator(),
          //             SizedBox(height: 20),
          //             Text('Connected to Spotify! Redirecting...')
          //           ],
          //         ),
          //       );
          //     }

          //     // Only show HomePage if both authenticated and Spotify connected
          //     return HomePage();
          //   },
          // );
        },
      ),
    );
  }
}
