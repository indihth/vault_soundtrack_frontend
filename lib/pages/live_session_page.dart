import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vault_soundtrack_frontend/services/database_services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/widgets/playlist_header.dart';
import 'package:vault_soundtrack_frontend/widgets/track_card.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/playlist_session_services.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

// Import local models and services
import '../models/playlist.dart';

/// LiveSessionPage: A StatefulWidget that displays the user's listening history
/// This is the main screen that shows all songs the user has played
class LiveSessionPage extends StatefulWidget {
  final bool viewingMode;
  const LiveSessionPage({Key? key, this.viewingMode = false}) : super(key: key);

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  /// The state class for LiveSessionPage

  // Create _sessionState variable to access session state in multiple methods
  late SessionState _sessionState;

  // Hanles UI when ending session
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _sessionState can't be initialised in initState
    // because widget isn't built yet and tries to access Provider
    _sessionState = Provider.of<SessionState>(context);

    // ignore session state changes if in viewing mode - would trigger rebuild
    if (widget.viewingMode) return;

    print('session state active didChanged running');

    // Check if session is ended and needs to redirect
    if (!_sessionState.isActive) {
      print('Session state: ${_sessionState.isActive}');
      print('Session is not active, redirecting...');
      handleSessionEnded();
      return;
    }

    final sessionId = _sessionState.sessionId;
    _sessionState.listenToSessionStatus(sessionId);
  }

  /// Handles common behavior when a session is ending or has ended
  /// for both host and guest users
  void handleSessionEnded() {
    // Stop listening to session status
    _sessionState.stopListeningToSessionStatus();

    // fetch updated user sessions and store in session state - update for dashboard UI
    _sessionState.refreshSessions();

    // Navigate away after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        navigateAndClearState();
      }
    });
  }

  Future<void> handleSavePlaylist() async {
    try {
      // Get session id from the Provider
      if (_sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }
      final success =
          await PlaylistSessionServices.savePlaylist(_sessionState.sessionId);
      if (success) {
        // TODO: Update 'save' button to show 'saved'

        // Show a success message to the user
        UIHelpers.showSnackBar(context, 'Playlist saved successfully!',
            isError: false);
      } else {
        UIHelpers.showSnackBar(context, 'Failed to save playlist',
            isError: true);
        throw Exception('Failed to save playlist');
      }
    } catch (e) {
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error saving playlist: $e');
    }
  }

  Future<void> navigateAndClearState() async {
    try {
      // set _isEnding to true to show loading spinner
      setState(() {
        _isEnding = true;
      });
      // navigate first
      await Navigator.pushReplacementNamed(context, '/home');
      print('Navigated to home page');

      // only if navigation complete, clear state
      _sessionState.clearSessionState();
    } catch (e) {
      // Handle any errors that occur during navigation
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error navigating to home: $e');
    } finally {
      // Reset _isEnding to false after navigation
      setState(() {
        _isEnding = false;
      });
    }
  }

  void handleEndSession() async {
    try {
      // Close the dialog
      Navigator.of(context).pop();

      // set _isEnding to true to show loading spinner
      setState(() {
        _isEnding = true;
      });

      final sessionId = _sessionState.sessionId;

      if (sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      await _sessionState.endSession(sessionId);

      // Use the common session ending handler
      // handleSessionEnded();
    } catch (e) {
      // Reset _isEnding to false in case of error
      setState(() {
        _isEnding = false;
      });

      // Display error message to the user
      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Error ending session: $e');
    }
  }

  // Sort tracks
  List<Track> sortTracks(List<Track> tracks) {
    // Sort the tracks by up votes in descending order
    final sortedTracks = List<Track>.from(tracks); // creates a copy of the list

    // calculate total votes for each track
    sortedTracks.sort((a, b) {
      // sort by total votes (upvotes - downvotes) in descending order
      int voteComparison =
          (b.upVotes - b.downVotes).compareTo(a.upVotes - a.downVotes);

      // return comparison if votes are not equal (a = 2, b = 1)
      if (voteComparison != 0) {
        return voteComparison;
      }

      // TODO: push new voted track to top tracks with same vote
      // keeps more recently voted tracks at the top
      // would require a timestamp or last voted property

      // If votes have equal value, sort by trackId in ascending order (stable sort, 2nd criteria)
      return a.trackId.compareTo(b.trackId);
    });

    return sortedTracks;
  }

  @override
  Widget build(BuildContext context) {
    // Get session state
    final isViewingMode = widget.viewingMode || _sessionState.isViewingMode;

    // the playlistId getting dynamically gets isViewing data if true
    final playlistId = isViewingMode
        ? _sessionState.viewingPlaylistId
        : _sessionState.playlistId;

    final isHost = _sessionState.isHost;
    final imageUrl = _sessionState.viewingImageUrl;

    if (_isEnding) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            DefaultTextStyle(
              // required because rendering before Scaffold is built
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14.0,
              ),
              child: Text('Ending session...'),
            ),
          ],
        ),
      );
    } else

    // Shows error message if no playlist Id is found but not when ending session
    if (playlistId.isEmpty) {
      return const Center(
        child: DefaultTextStyle(
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
            child: Text('No playlist ID found')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              if (isViewingMode) {
                // clear only viewing state when exiting viewing mode
                _sessionState.clearViewingState();
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            icon: const Icon(Icons.arrow_back)),
        // let user navigate back to homepage - adjust stack after joining
        // automaticallyImplyLeading: false, // automatically hides added back btn
        actions: [
          if (!isViewingMode) // don't show QR code in viewing mode
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                // Get session ID from provider
                final sessionId = _sessionState.sessionId;
                final qrCodeText = '$sessionId, late';
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Scan to join',
                      textAlign: TextAlign.center,
                    ),
                    content: SizedBox(
                      width: 180,
                      height: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: qrCodeText,
                            // version: QrVersions.auto,
                            backgroundColor: Colors.white,
                            // padding: EdgeInsets.all(10),
                            size: 170.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<Playlist>(
        // uses either a Future or a Stream depending on viewing mode - view only fetches once, no updates
        stream: isViewingMode
            ? Stream.fromFuture(_getPlaylistOnce(playlistId))
            : _getPlaylistStream(playlistId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // loading spinner while data is being fetched
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // show error message if data fetching failed
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.tracks.isEmpty) {
            // show message when no history data exists
            return const Center(
              child: Text('No listening history found'),
            );
          } else {
            Playlist playlist = snapshot.data!;

            // create a sorted copy of the tracks list
            List<Track> sortedTracks = sortTracks(playlist.tracks);

            // builds a scrollable list of history items
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  PlaylistHeader(
                    item: playlist,
                    isHost: isViewingMode ? false : isHost,
                    handleEndSession: handleEndSession,
                    handleSavePlaylist: handleSavePlaylist,
                    isViewingMode: isViewingMode,
                    imageUrl: imageUrl,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sortedTracks.length,
                      itemBuilder: (context, index) {
                        Track track = sortedTracks[index];
                        return TrackCard(
                          // use ObjectKey to uniquely identify each track - solves UI issue when reordering tracks
                          key: ObjectKey(track.trackId),
                          item: track,
                          isViewingMode:
                              isViewingMode, // show/hide voting buttons
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Stream to listen to playlist changes from Firestore
  Stream<Playlist> _getPlaylistStream(String playlistId) {
    // Check if playlistId is empty or null
    if (playlistId.isEmpty) {
      // Return an empty stream that emits an error
      return Stream.error('Invalid playlist ID');
    }

    try {
      return FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          return Playlist.fromFirestore(snapshot);
        }
        throw Exception('Playlist not found');
      });
    } catch (e) {
      print('Error creating stream: $e');
      return Stream.error('Failed to create playlist stream: $e');
    }
  }

// for viewing mode - only fetch once
  Future<Playlist> _getPlaylistOnce(String playlistId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('playlists')
          .doc(playlistId)
          .get();

      if (doc.exists) {
        return Playlist.fromFirestore(doc);
      }
      throw Exception('Playlist not found');
    } catch (e) {
      print('Error loading playlist: $e');
      throw Exception('Failed to load playlist: $e');
    }
  }
}
