import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/components/my_button.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';

class CreateSessionPage extends StatefulWidget {
  const CreateSessionPage({super.key});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  String? sessionMessage; // message from the server API request

  handleStartSession() async {
    try {
      // make the API request and store in response
      String response = await PlaylistSessionServices.createPlaylistSession();

      // set the response to the sessionMessage state
      setState(() {
        sessionMessage = response;
      });
    } catch (e) {
      setState(() {
        sessionMessage = e.toString();
      });
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
              Text('Create Session Page'),
              MyButton(
                text: "Start session",
                onTap: handleStartSession,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
