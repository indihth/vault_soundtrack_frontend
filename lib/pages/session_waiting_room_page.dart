import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/my_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vault_soundtrack_frontend/widgets/vote_icon.dart';

class SessionWaitingRoomPage extends StatefulWidget {
  const SessionWaitingRoomPage({super.key});

  @override
  State<SessionWaitingRoomPage> createState() => _SessionWaitingRoomPageState();
}

class _SessionWaitingRoomPageState extends State<SessionWaitingRoomPage> {
// Voting demo state variables
  bool _demoIsUpVoted = false;
  bool _demoIsDownVoted = false;
  int _demoUpVoteCount = 0;
  int _demoDownVoteCount = 0;

// Voting demo logic
  void _handleDemoVote(String voteType) {
    setState(() {
      if (voteType == 'up') {
        // Toggle upvote
        if (_demoIsUpVoted) {
          _demoIsUpVoted = false;
          _demoUpVoteCount--;
        } else {
          _demoIsUpVoted = true;
          _demoUpVoteCount++;

          // Remove downvote if exists
          if (_demoIsDownVoted) {
            _demoIsDownVoted = false;
            _demoDownVoteCount--;
          }
        }
      } else {
        // Toggle downvote
        if (_demoIsDownVoted) {
          _demoIsDownVoted = false;
          _demoDownVoteCount--;
        } else {
          _demoIsDownVoted = true;
          _demoDownVoteCount++;

          // Remove upvote if exists
          if (_demoIsUpVoted) {
            _demoIsUpVoted = false;
            _demoUpVoteCount--;
          }
        }
      }
    });
  }

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
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        // Text(
                        //   sessionState.sessionDescription,
                        //   textAlign: TextAlign.center,
                        //   style:
                        //       Theme.of(context).textTheme.titleMedium?.copyWith(
                        //             color: Colors.grey,
                        //           ),
                        // ),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Joined users
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   'Users joined: ',
                        //   style: Theme.of(context).textTheme.bodyLarge,
                        // ),
                        const SizedBox(height: 6),

                        // Display list of users in session
                        Consumer<SessionState>(
                          builder: (context, sessionState, _) {
                            if (sessionState.sessionUsers.isEmpty) {
                              return Center(
                                child: Text(
                                  '...',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            // Join user names with commas
                            final userNames = sessionState.sessionUsers
                                .map((user) =>
                                    user['displayName'] ?? 'Unknown User')
                                .join(' | ');

                            return Text(
                              userNames,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                              softWrap: true,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // Display instructions for host and users
                Column(
                  children: [
                    Text(
                      'You can vote on tracks, try it out!',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tracks with 2 or more down votes will not \nbe added to the playlist.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),

                    // A demo version of the voting feature that allows user to vote
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VoteIcon(
                          isUpVote: true,
                          isVoted: _demoIsUpVoted,
                          isLoading: false,
                          voteCount: _demoUpVoteCount,
                          onTap: () => _handleDemoVote('up'),
                        ),
                        const SizedBox(width: 20),
                        VoteIcon(
                          isUpVote: false,
                          isVoted: _demoIsDownVoted,
                          isLoading: false,
                          voteCount: _demoDownVoteCount,
                          onTap: () => _handleDemoVote('down'),
                        ),
                      ],
                    ),
                  ],
                ),

                // Button section
                Column(
                  children: [
                    // Display button only to host
                    if (sessionState.isHost)
                      MyButton(
                        text: "Start session",
                        // onTap: displayUsersInSession,
                        onTap: handleTap,
                        fullWidth: true,
                      ),

                    // For users
                    if (!sessionState.isHost)
                      Text(
                        'The host will start the session \nwhen everyone is ready',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
