import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/voting.services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

/// Shows song details including artwork, name, artist, album, and when it was played
class TrackCard extends StatefulWidget {
  // The data model containing all information about this history item
  final Track item;

  TrackCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<TrackCard> createState() => _TrackCardState();
}

class _TrackCardState extends State<TrackCard> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late int upVotes;
  late int downVotes;
  late bool isUpVoted;
  late bool isDownVoted;

  @override
  void initState() {
    super.initState();

    // State variables for voting
    upVotes = widget.item.upVotes; // get upvotes from the track
    downVotes = widget.item.downVotes; // get downvotes from the track
    isUpVoted = widget.item.hasUserUpVoted(userId); // check if user has upvoted
    isDownVoted =
        widget.item.hasUserDownVoted(userId); // check if user has downvoted
  }

  void _addUpVote() {
    setState(() {
      isUpVoted = true;
      upVotes += 1;
    });
  }

  void _removeUpVote() {
    setState(() {
      isUpVoted = false;
      upVotes -= 1;
    });
  }

  void _addDownVote() {
    setState(() {
      isDownVoted = true;
      downVotes += 1;
    });
  }

  void _removeDownVote() {
    setState(() {
      isDownVoted = false;
      downVotes -= 1;
    });
  }

  // handle optamistic UI update on voting
  void updateVoteUI(String voteType) async {
    // update vote state

    // Handle vote and count logic
    if (voteType == 'up') {
      if (isUpVoted) {
        // If state is already upvoted, remove upvote
        _removeUpVote();
      } else if (isDownVoted) {
        // If state is downvoted, remove downvote and add upvote
        _addUpVote();
        _removeDownVote();
      } else {
        // If state is not upvoted or downvoted, add upvote
        _addUpVote();
      }

      // Handle downvote logic
    } else if (voteType == 'down') {
      if (isDownVoted) {
        _removeDownVote();
      } else if (isUpVoted) {
        _addDownVote();
        _removeUpVote();
      } else {
        _addDownVote();
      }
    }
  }

// handle upvote with voting services
  void handleVote(context, track, voteType) async {
    // Store original state for potential revert
    final originalUpVotes = upVotes;
    final originalDownVotes = downVotes;
    final originalIsUpVoted = isUpVoted;
    final originalIsDownVoted = isDownVoted;

    // update UI optimistically - show the vote before it's confirmed by server
    updateVoteUI(voteType);

    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      if (sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      await VotingServices.handleVote(sessionState.sessionId,
          sessionState.playlistId, track.trackId, voteType);
    } catch (e) {
      // Revert UI states if voting fails
      setState(() {
        upVotes = originalUpVotes;
        downVotes = originalDownVotes;
        isUpVoted = originalIsUpVoted;
        isDownVoted = originalIsDownVoted;
      });

      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Failed to upvote song: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                widget.item.albumArtworkUrl,
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
                    widget.item.songName,
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
                    widget.item.artistName,
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
                    widget.item.albumName,
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
                  onTap: () => handleVote(context, widget.item, "up"),
                  child: Column(
                    children: [
                      Icon(
                        isUpVoted
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        upVotes.toString(), // Handle null values by showing '0'
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
                  onTap: () => handleVote(context, widget.item, "down"),
                  child: Column(
                    children: [
                      Icon(
                        isDownVoted
                            ? Icons.thumb_down
                            : Icons.thumb_down_alt_outlined,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        downVotes
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
