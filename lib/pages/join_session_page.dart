import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/services/spotify_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

class JoinSessionPage extends StatelessWidget {
  const JoinSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Create Session Page'),
              MyButton(
                  text: 'Create a session',
                  onTap: PlaylistSessionServices.joinPlaylistSession)
            ],
          ),
        ),
      ),
    );
  }
}
