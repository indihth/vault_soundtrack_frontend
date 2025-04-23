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
  bool _isInitialized = false; // Track initialization state
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();

    // initialize UserState
    _userState = Provider.of<UserState>(context, listen: false);

    // waits until the widget is fully built before calling _initializeUserState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserState();
    });
  }

  // user state must be handled after widget is mounted to avoid calling setState on unmounted widget
  Future<void> _initializeUserState() async {
    await _userState.updateUserState();
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _isLoading = false; // Set loading to false after initialization
      });
    }
  }

  // Future<void> _handleSpotifyConnectionSuccess() async {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _userState.clearNewUserFlag();
  //     // Navigate to home after successful connection
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomePage()),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // listens to auth state - if user is logged in or not
      body: StreamBuilder<User?>(
        // was missing the type parameter <User?> so it wasn't getting updates properly
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print(
              'AuthPage StreamBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}');

          // Show login/register if not authenticated
          if (!snapshot.hasData) {
            if (_isInitialized) {
              // reset the state when logged out, clean for next login

              // Future.microtastk is used to ensure that the state is reset after the widget is built
              // and not before, preventing any potential issues with the widget tree
              Future.microtask(() {
                _userState.resetState();
              });
            }
            return LoginOrRegister();
          }

          // If we haven't initialized user state yet or it's loading, show loading
          if (_isLoading || !_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          // User is authenticated, now check Spotify connection
          return Consumer<UserState>(
            builder: (context, userState, _) {
              // If not connected to Spotify, force ConnectSpotifyPage
              if (userState.isNewUser && !userState.isSpotifyConnected) {
                return PopScope(
                  child: const ConnectSpotifyPage(),
                );
              } else if (userState.isNewUser && userState.isSpotifyConnected) {
                // only after widget is built - avoids calling setState on unmounted widget
                // previousl setup caused a flash of the homescreen before the transition to ConnectSpotifyPage

                // schedules navigation callback after the widget is built
                Future.microtask(() {
                  userState.clearNewUserFlag();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => HomePage()),
                      (route) => false // remove all previous routes
                      );
                });

                // laoding indicator during the transition
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Connected to Spotify! Redirecting...')
                    ],
                  ),
                );
              }

              // Only show HomePage if both authenticated and Spotify connected
              return HomePage();
            },
          );
        },
      ),
    );
  }
}
