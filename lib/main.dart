import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/auth/auth.dart';
import 'package:vault_soundtrack_frontend/firebase_options.dart';
import 'package:vault_soundtrack_frontend/pages/connect_spotify_page.dart';
import 'package:vault_soundtrack_frontend/pages/create_session_page.dart';
import 'package:vault_soundtrack_frontend/pages/join_session_page.dart';
import 'package:vault_soundtrack_frontend/pages/listening_history_page.dart';
import 'package:vault_soundtrack_frontend/theme/light_mode.dart';
import 'package:vault_soundtrack_frontend/theme/dark_mode.dart';

void main() async {
  // initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: lightMode,
        darkTheme: darkMode,
        debugShowCheckedModeBanner: false,
        // home: ListeningHistoryPage(),
        home: AuthPage(),
        routes: {
          '/auth': (context) => const AuthPage(),
          '/create-session': (context) => const CreateSessionPage(),
          '/join-session': (context) => const JoinSessionPage(),
          '/live-session': (context) => const ListeningHistoryPage(),
          '/connect-spotify': (context) => const ConnectSpotifyPage(),
          // '/manage-spotify': (context) => const ManageSpotifyPage(),
        });
  }
}
