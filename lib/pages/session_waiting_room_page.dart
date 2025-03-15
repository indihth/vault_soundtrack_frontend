import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'package:vault_soundtrack_frontend/models/user_profile.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';

class SessionWaitingRoomPage extends StatefulWidget {
  const SessionWaitingRoomPage({super.key});

  @override
  State<SessionWaitingRoomPage> createState() => _SessionWaitingRoomPageState();
}

class _SessionWaitingRoomPageState extends State<SessionWaitingRoomPage> {
  void handleTap() {
    // Redirect to live session page
    Navigator.pushNamed(context, '/live-session');
  }

  // Display current users in session
  Future<List<UserProfile>> displayUsersInSession() async {
    // Get all users in session
    final users = await PlaylistSessionServices.getSessionUsers();
    // Display users in session
    print(users);
    return users;
  }

  // Listen for new users joining session

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Waiting for all users to join...',
                style: TextStyle(
                    fontSize: 24, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Press button when ready',
                // style: TextStyle(fontSize: 24),
              ),
              MyButton(
                text: "Lets go!",
                // onTap: displayUsersInSession,
                onTap: handleTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
