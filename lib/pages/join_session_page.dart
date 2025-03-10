import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/services/spotify_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class JoinSessionPage extends StatelessWidget {
  const JoinSessionPage({super.key});

  Future<void> handleTap(context) async {
    try {
      bool joined = await PlaylistSessionServices.joinPlaylistSession();
      if (joined) {
        Navigator.pushNamed(context, '/waiting-room');
        print("joined session!!");
      }
    } catch (e) {
      // Handle error
    }
  }

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
              Text('Join Session Page'),
              MyButton(
                  text: 'Join a session',
                  onTap: () => handleTap(
                      context)), // wrap in anon function to pass context
            ],
          ),
        ),
      ),
    );
  }
}
