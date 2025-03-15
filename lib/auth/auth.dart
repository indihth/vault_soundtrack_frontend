import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/auth/login_or_register.dart';
import 'package:vault_soundtrack_frontend/pages/home_page.dart';

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
            return HomePage();
          } else {
            return LoginOrRegister();
          }

          // if user is not logged in
        },
      ),
    );
  }
}
