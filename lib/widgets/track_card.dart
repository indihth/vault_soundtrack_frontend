import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/voting.services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

/// Shows song details including artwork, name, artist, album, and when it was played
class TrackCard extends StatelessWidget {
  // The data model containing all information about this history item
  final Track item;

  TrackCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  final userId = FirebaseAuth.instance.currentUser?.uid;

// handle upvote with voting services
  void handleVote(context, track, voteType) async {
    print('Upvoting song: ${track.songName}');
    final sessionState = Provider.of<SessionState>(context, listen: false);
    if (sessionState.sessionId.isEmpty) {
      throw Exception('Session ID state is empty');
    }

    try {
      await VotingServices.handleVote(sessionState.sessionId,
          sessionState.playlistId, track.trackId, voteType);
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Failed to upvote song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get if user has up voted/down for this track
    bool isUpVoted = item.hasUserUpVoted(userId);
    bool isDownVoted = item.hasUserDownVoted(userId);

    return Card(
      // is a card widget appropriate here?
      // margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0, // removes shadow
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Artwork section
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(2.0), // Rounded corners for the image
              child: Image.network(
                item.albumArtworkUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Handle image loading errors gracefully
                errorBuilder: (context, error, stackTrace) {
                  // If image loading fails, show a placeholder
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0), // Spacing between image and text
            // Song details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song name with ellipsis if too long
                  Text(
                    item.songName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Truncate with ... if text is too long
                  ),
                  const SizedBox(height: 4.0), // Vertical spacing
                  // Artist name
                  Text(
                    item.artistName,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Album name
                  Text(
                    item.albumName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // dispay icon if song is liked
            // if (item.isLiked)

            SizedBox(width: 8.0), // Spacing between icons

            // Upvote icon
            Column(
              children: [
                GestureDetector(
                  onTap: () => handleVote(context, item, "up"),
                  child: Column(
                    children: [
                      if (isUpVoted)
                        const Icon(
                          Icons.thumb_up,
                          color: Colors.blue,
                        )
                      else
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Colors.blue,
                        ),
                      const SizedBox(height: 4.0),
                      Text(
                        item.upVotes
                            .toString(), // Handle null values by showing '0'
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(width: 8.0), // Spacing between icons

            // Downvote icon
            Column(
              children: [
                GestureDetector(
                  onTap: () => handleVote(context, item, "down"),
                  child: Column(
                    children: [
                      if (isDownVoted)
                        const Icon(
                          Icons.thumb_down,
                          color: Colors.grey,
                        )
                      else
                        const Icon(
                          Icons.thumb_down_alt_outlined,
                          color: Colors.grey,
                        ),
                      const SizedBox(height: 4.0),
                      Text(
                        item.downVotes
                            .toString(), // Handle null values by showing '0'
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
