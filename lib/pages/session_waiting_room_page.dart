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
  @override
  void initState() {
    super.initState();
  }

  // Flutter lifecycle method - Runs after initState, when dependencies change and before build()
  // It will be called whenever SessionState changes, redirect when session is active
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('session state active didChanged running');

    // Check if session is active and needs to redirect
    final sessionState = Provider.of<SessionState>(context, listen: true);
    sessionState.listenToSessionStatus(sessionState.sessionId);

    print('session state active didChanged: ${sessionState.isActive}');

    if (sessionState.isActive && !sessionState.isHost) {
      // Use addPostFrameCallback to ensure the navigation happens after the build is complete
      // Otherwise potential error trying to navigate while the widget is still building
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/live-session');
      });
    }
  }

  void handleTap() async {
    try {
      // Get session state data
      final sessionState = Provider.of<SessionState>(context, listen: false);

      // Display error is a non-host tries to start the session - shouldn't be possible though
      if (!sessionState.isHost) {
        UIHelpers.showSnackBar(context, 'Only the host can start the session',
            isError: true);
        return;
      }

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

      // Update session status in db
      await PlaylistSessionServices.updateSessionStatus(
          sessionState.sessionId, 'active');

      // Close loading dialog
      Navigator.pop(context);

      // Save playlistId in session state if it's not null
      if (playlistId.isNotEmpty) {
        sessionState.setPlaylistId(playlistId);
        sessionState.setIsActive(true); // Set session as active

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // QR code section and title
              Column(
                children: [
                  Column(
                    children: [
                      Text(
                        sessionState.sessionName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        sessionState.sessionDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // QR code
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: QrImageView(
                          data: sessionState.sessionId,
                          // 'sample://open.my.app/#/join-session/${sessionState.sessionId}',
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
                      ),
                      // display session name and description
                      const SizedBox(height: 6),
                      Text(
                        "Scan QR code to join",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),

              // Center text section
              Column(
                children: [
                  Text(
                    'Users joined: ',
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 6),

                  // Display list of users in session
                  Consumer<SessionState>(
                    builder: (context, sessionState, _) {
                      if (sessionState.sessionUsers.isEmpty) {
                        return Center(
                          child: Text(
                            '...',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      // Join user names with commas
                      final userNames = sessionState.sessionUsers
                          .map((user) => user['displayName'] ?? 'Unknown User')
                          .join(' | ');

                      return Text(
                        userNames,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                        softWrap: true,
                      );
                    },
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                    'Tracks with 2 or more down votes will not be added \nto the playlist.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center),
              ),
              // Button section
              Column(
                children: [
                  // Display button only to host
                  if (sessionState.isHost)
                    MyButton(
                      text: "Lets go!",
                      // onTap: displayUsersInSession,
                      onTap: handleTap,
                    ),
                  SizedBox(height: 8),

                  // For users
                  if (!sessionState.isHost) ...[
                    Text(
                      'The host will start the session \nwhen everyone is ready',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),

                    // For host
                  ] else ...[
                    Text(
                      "Continue when all users have joined",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
              SizedBox(height: 14)
            ],
          ),
        ),
      ),
    );
  }
}
