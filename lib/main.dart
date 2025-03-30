import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/auth/auth.dart';
import 'package:vault_soundtrack_frontend/pages/home_page.dart';
import 'package:vault_soundtrack_frontend/pages/session_list_page.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/widgets/deep_link_listener.dart';
import 'package:vault_soundtrack_frontend/firebase_options.dart';
import 'package:vault_soundtrack_frontend/pages/connect_spotify_page.dart';
import 'package:vault_soundtrack_frontend/pages/create_session_page.dart';
import 'package:vault_soundtrack_frontend/pages/join_session_page.dart';
import 'package:vault_soundtrack_frontend/pages/live_session_page.dart';
import 'package:vault_soundtrack_frontend/pages/session_waiting_room_page.dart';
import 'package:vault_soundtrack_frontend/theme/light_mode.dart';
import 'package:vault_soundtrack_frontend/theme/dark_mode.dart';

void main() async {
  // initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // initialize AppLinks
  final appLinks = AppLinks();

  // listen for incoming links
  final sub = appLinks.uriLinkStream.listen((Uri uri) {
    print('Received uri: ${uri.toString()}');
  });

// Wrap the app in a ChangeNotifierProvider to provide the SessionState
  runApp(ChangeNotifierProvider(
      create: (context) => SessionState(), child: const MyApp()));
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
        home: DeepLinkListener(child: AuthPage()),
        routes: {
          '/auth': (context) => const AuthPage(),
          '/home': (context) => HomePage(),
          '/create-session': (context) => const CreateSessionPage(),
          '/join-session': (context) => const JoinSessionPage(
                sessionId: 'undefined',
              ),
          '/live-session': (context) => const LiveSessionPage(),
          '/session-list': (context) => const SessionListPage(),
          '/connect-spotify': (context) => const ConnectSpotifyPage(),
          '/waiting-room': (context) => const SessionWaitingRoomPage(),
          // '/manage-spotify': (context) => const ManageSpotifyPage(),
        });
  }
}
