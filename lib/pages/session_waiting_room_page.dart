import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SessionWaitingRoomPage extends StatefulWidget {
  const SessionWaitingRoomPage({super.key});

  @override
  State<SessionWaitingRoomPage> createState() => _SessionWaitingRoomPageState();
}

class _SessionWaitingRoomPageState extends State<SessionWaitingRoomPage> {
  void handleTap() {
    // Redirect to live session page
    Navigator.pushNamed(context, '/live-session');
    print('Redirecting to live session page');
  }

  // TODO: display users as they join

  @override
  Widget build(BuildContext context) {
    // Get Session State
    final sessionState = Provider.of<SessionState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // display session name and description
              Text(
                sessionState.sessionName,
                style: TextStyle(
                    fontSize: 24, color: Theme.of(context).colorScheme.primary),
              ),
              Text(
                sessionState.sessionDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
              Text(
                sessionState.hostDisplayName,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary),
              ),
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
              const SizedBox(height: 20),
              Text(
                'Invite friends to join your session',
                style: TextStyle(
                    fontSize: 24, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data:
                    'sample://open.my.app/#/join-session/${sessionState.sessionId}',
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                padding: EdgeInsets.all(10),
                errorStateBuilder: (cxt, err) {
                  return Center(
                    child: Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
