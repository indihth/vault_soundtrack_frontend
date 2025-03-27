import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SessionWaitingRoomPage extends StatefulWidget {
  const SessionWaitingRoomPage({super.key});

  @override
  State<SessionWaitingRoomPage> createState() => _SessionWaitingRoomPageState();
}

class _SessionWaitingRoomPageState extends State<SessionWaitingRoomPage> {
  // void handleTap() async {
  //   try {
  //     // Get session state data
  //     final sessionState = Provider.of<SessionState>(context, listen: false);

  //     // Start playlist session from services
  //     final playlistId = await PlaylistSessionServices.startPlaylistSession(
  //         sessionState.sessionId);

  //     // Save playlistId in session state
  //     sessionState.setPlaylistId(playlistId);
  //     print('Playlist ID: $playlistId');

  //     // Redirect to live session page on success
  //     Navigator.pushNamed(context, '/live-session',
  //         arguments: {'playlistId': playlistId});
  //     print('Redirecting to live session page');
  //   } catch (e) {
  //     print('Error starting session: $e');
  //     throw Exception('Error starting session: $e');
  //   }
  // }

  void handleTap() async {
    try {
      // Get session state data
      final sessionState = Provider.of<SessionState>(context, listen: false);

      // Start playlist session from services - show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Call the API
      final playlistId = await PlaylistSessionServices.startPlaylistSession(
          sessionState.sessionId);

      // Close loading dialog
      Navigator.pop(context);

      // Save playlistId in session state if it's not null
      if (playlistId != null && playlistId.isNotEmpty) {
        sessionState.setPlaylistId(playlistId);

        // Navigate using replacement to avoid stack issues
        Navigator.pushReplacementNamed(
          context,
          '/live-session',
        );
      } else {
        UIHelpers.showSnackBar(
            context, 'Failed to start session: Invalid playlist ID',
            isError: true);
      }
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.maybeOf(context)?.pop();

      // Show error message
      UIHelpers.showSnackBar(context, 'Error starting session: $e',
          isError: true);
      print('Error starting session: $e');
    }
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
