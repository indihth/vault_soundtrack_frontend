import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';

class PlaylistHeader extends StatelessWidget {
  final VoidCallback handleSavePlaylist;
  final VoidCallback handleEndSession;
  final Playlist item;
  final bool isHost;
  final bool isViewingMode;
  final String imageUrl; // Placeholder image

  const PlaylistHeader(
      {super.key,
      required this.item,
      required this.isHost,
      this.isViewingMode = false,
      this.imageUrl = '',
      required this.handleSavePlaylist,
      required this.handleEndSession});

  // Confirms if the user wants to end the session
  void _confirmEndSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'),
          content: const Text(
            'Are you sure you want to end the session?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: handleEndSession,
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display playlist image if 'viewing'
            if (isViewingMode)
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(3), // rounded corners on image only
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity, // full width of parent
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error_outline, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(width: 20),

            // Display playlist title and description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<SessionState>(
                builder: (context, sessionState, _) {
                  if (sessionState.sessionUsers.isEmpty) {
                    return Text(
                      'Waiting for users to join...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
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
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: handleSavePlaylist,
              icon: Icon(Icons.playlist_play,
                  color: Theme.of(context).colorScheme.tertiary),
              label: Text(
                'Save',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            if (isHost) ...[
              // Only host can end the session
              const SizedBox(width: 20),
              // Add a button to shuffle the playlist
              ElevatedButton(
                onPressed: () {
                  _confirmEndSession(context);
                },
                // onPressed: handleEndSession,
                child: const Text('End Session'),
              ),
            ]
          ],
        ),
        SizedBox(height: 8),

        // only displayed if in live session
        // if (!isViewingMode) ...[
        //   Text(
        //       'Tracks with 2 or more down votes will not be added \nto the playlist.',
        //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
        //             color: Colors.grey,
        //           ),
        //       textAlign: TextAlign.center),
        //   SizedBox(height: 8),
        // ]
      ],
    );
  }
}
