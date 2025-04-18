import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/auth/login_or_register.dart';
import 'package:vault_soundtrack_frontend/pages/connect_spotify_page.dart';
import 'package:vault_soundtrack_frontend/pages/home_page.dart';
import 'package:vault_soundtrack_frontend/services/user_services.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // listens to auth state - if user is logged in or not
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // if user is logged in
          if (snapshot.hasData) {
            // check if user has connected to Spotify
            return FutureBuilder<bool>(
              future: UserServices.checkSpotifyConnection(),
              builder: (context, spotifySnapshot) {
                if (spotifySnapshot.hasError) {
                  // Handle the error state
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          spotifySnapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Refresh the page or retry the connection
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (spotifySnapshot.hasData) {
                  return spotifySnapshot.data!
                      ? HomePage() // if user is connected to Spotify, show homepage
                      : ConnectSpotifyPage(); // otherwise, show connect page
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          } else {
            // if user is not logged in
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}
